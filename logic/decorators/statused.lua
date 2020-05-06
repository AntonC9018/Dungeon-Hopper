local utils = require 'logic.decorators.utils'
local Changes = require 'render.changes'
local Decorator = require 'logic.decorators.decorator'
local Stats = require 'logic.stats.stats'
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Ranks = require 'lib.chains.ranks'
local Event = require 'lib.chains.event'


local status = function(event)
    -- get resistances
    local resistance = event.actor:getStat(StatTypes.StatusRes)
    local statuses = event.actor.statuses

    -- event.status is a Stats object that has stats applied to us
    -- we have to loop through stats manually, so that we call
    -- all necessary methods on Status objects right
    for k, v in pairs(event.action.status.stats) do
        -- TODO: look up how much of a status to apply in
        -- the status definition table 
        local newAmount = 2
        
        -- apply the stat, if resistance is low
        if resistance:get(k) <= v then

            print("Applying the "..k.." status")

            if statuses:get(k) == 0 then
                -- TODO: call apply method on the status object
            else
                -- TODO: call the reapply method on the status object
            end
            
            -- for now, reset the stat to the new amount.
            -- TODO: possibly add different methods of this, like addition vs resetting
            statuses:set(k, newAmount)

        end
    end
end


local function tick(event)
    local t = event.actor.statuses.stats
    for k, v in pairs(t) do
        if v > 0 then
            printf("Tinking test status. Current amount: %i", v)
            local newAmount = v - 1
            
            if newAmount == 0 then
                -- TODO: Call the wearOff() method on statuses
                -- TODO: queue the status effect for applying the free() method
                -- next turn
                t[k] = nil 
            else
                t[k] = newAmount
            end
        end
    end
end


local function free(event)
    -- TODO: loop through all queued statuses, check if amount is still 0
    -- if it is, call their wearOff() method
end

local Statused = class('Statused', Decorator)

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


-- Create the status stats object
function Statused:__construct(actor)
    self.statuses = Stats()
    actor.statuses = self.statuses
end

-- Get current stats
function Statused:get()
    return self.statuses
end

return Statused