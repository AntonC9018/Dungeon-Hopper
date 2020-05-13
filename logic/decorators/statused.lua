local utils = require '@decorators.utils'
local Changes = require 'render.changes'
local Decorator = require '@decorators.decorator'
local Stats = require '@stats.stats'
local DynamicStats = require '@decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Ranks = require 'lib.chains.ranks'
local Event = require 'lib.chains.event'
local Overlay = require '@status.overlay'

local Statused = class('Statused', Decorator)


-- Now how do we actually store status effects
local StatusList = {}
local StatusIndexToName = {}
statusTypesLength = 0
Statused.StatusTypes = {}

Statused.registerStatus = function(name, status) 
    statusTypesLength = statusTypesLength + 1
    Statused.StatusTypes[name] = statusTypesLength
    StatusList[statusTypesLength] = status
    StatusIndexToName[statusTypesLength] = name

    -- now, gotta modify the DynamicStats to include it in resistances
    DynamicStats.addAttribute(
        StatTypes.StatusRes, 
        { name, 1 }
    )

    -- and in statuses
    DynamicStats.addAttribute(
        StatTypes.Status, 
        { name, 0 }
    )
end


function Statused:__construct(actor)
    -- Create the status stats object
    self.statuses = Stats()
    actor.statuses = self.statuses

    -- stores the status effects that have to be pinged in free
    self.queue = {}
    self.actor = actor
end

-- Get current stats
function Statused:get()
    return self.statuses
end

function Statused:resetStatus(statusIndex)
    if self.statuses.stats[ StatusIndexToName[statusIndex] ] == nil then 
        return 
    end
    print("Resetting "..StatusIndexToName[statusIndex])
    self.statuses.stats[ StatusIndexToName[statusIndex] ] = nil

    local statusEffect = StatusList[statusIndex]
    statusEffect:wearOff(self.actor)
    table.insert(self.queue, statusEffect)
end


local status = function(event)
    -- get resistances
    local actor = event.actor
    local resistance = actor:getStat(StatTypes.StatusRes)
    local statuses = actor.statuses

    -- event.status is a Stats object that has stats applied to us
    -- we have to loop through stats manually, so that we call
    -- all necessary methods on Status objects right
    for k, v in pairs(event.action.status.stats) do
        
        local statusEffect = StatusList[ Statused.StatusTypes[k] ]
        
        -- The amount is currently specified by the status effect itself
        local newAmount = statusEffect.amount
        
        
        -- apply the stat, if resistance is low
        if resistance:get(k) <= v then

            -- print("Applying the "..k.." status") -- debug

            if statuses:get(k) == 0 then
                statusEffect:apply(actor, newAmount)
            else
                statusEffect:reapply(actor, newAmount)
            end

            if statusEffect.overlay == Overlay.ADD then
                statuses:add(k, newAmount)
            elseif statusEffect.overlay == Overlay.RESET then
                statuses:set(k, newAmount)
            else
                error("What overlay method is this status using?")
            end

        end
    end
end


local function tick(event)
    local actor = event.actor   
    local t = actor.statuses.stats

    for k, v in pairs(t) do
        if v > 0 then
            -- printf("Ticking "..k.." status. Current amount: %i", v) -- debug
            local newAmount = v - 1
            
            if newAmount == 0 then                
                event.actor.decorators.Statused
                    :resetStatus(Statused.StatusTypes[k])
            else
                t[k] = newAmount
            end
        end
    end
end

-- TODO: this is probably not needed. Such stuff can be implemented via 
-- invincibility, but we'll see
local function free(event)
    -- loop through all queued statuses, check if amount is still 0
    -- if it is, call their free() method
    for _, statusEffect in ipairs(event.actor.decorators.Statused.queue) do
        statusEffect:free(event.actor)
    end
    event.actor.decorators.Statused.queue = {}
end


Statused.affectedChains = {
    { 'status', 
        { 
            status,
            utils.regChangeFunc(Changes.Status)
        } 
    },
    { 'tick',
        {
            tick
        }
    },
    { 'checkAction',
        {
            { free, Ranks.HIGHEST }
        }
    }
}

-- this applies new statuses
function Statused:activate(actor, action)
    local event = Event(actor, action)
    actor.chains.status:pass(event, Chain.checkPropagate)
    event.success = true
    return event
end

return Statused