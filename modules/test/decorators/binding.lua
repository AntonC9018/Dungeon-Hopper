local Decorator = require '@decorators.decorator'
local utils = require '@decorators.utils'
local Changes = require 'render.changes'

-- TODO: this one should be customizable
local BindFlavors = require '.status.flavors.bind'

-- Define our custom decorator
local Binding = class('Binding', Decorator)

-- define the handlers for the chains
local function setBase(event)
    event.action.status = event.actor:getStat(StatTypes.Status)
end

local function getTarget(event)
    local actor = event.actor
    local entity = actor.world.grid:getRealAt(actor.pos + event.action.direction)
    if entity == nil then
        event.propagate = false
    else
        event.target = entity
    end
end

local function checkAlreadyBound(event)
    event.propagate = event.target.statuses:get('bind') == 0

end

local function bindTarget(event)
    local bindOptions = {
        whoApplied = event.actor,
        flavor = BindFlavors.NoMove
    }
    event.statusEvent = event.target:beStatused(event.action, { bind = bindOptions })
end


local function register(event)
    -- if bound were successful, the stat on entity is not 0
    local success = event.target.statuses:get('bind') ~= 0 
    
    -- remove oneself from grid
    event.actor.world.grid:remove(event.actor)
    -- move to the player's position
    event.actor.pos = event.target.pos

    -- if the bind did get applied,
    if success then
        -- register that on the actor
        event.actor.decorators.Binding.boundEntity = event.target
        -- change state to 2
        event.actor.state = 2
        -- TODO: in some way increase health
        -- TODO: 
    else 
        -- for now just die
        event.actor:die()
    end
end

-- if the host dies, release the bounding entity
function Binding:isActivated()
    return self.boundEntity ~= nil
end

local function freeIfHostIsDead(event)
    local binding = event.actor.decorators.Binding
    if 
        binding.boundEntity ~= nil 
        and binding.boundEntity.dead 
    then
        binding.boundEntity = nil
    end
end

local function skipDisplaceIfBinding(event)
    event.propagate = not event.actor.decorators.Binding:isActivated()
end

Binding.affectedChains = {
    { 'getBind', 
        { 
            setBase, 
            getTarget, 
            checkAlreadyBound 
        } 
    },
    { 'bind', 
        { 
            bindTarget,
            register,
            utils.regChangeFunc(Changes.JustState)
        } 
    },
    { 'displace',
        {   -- prevent being displaced
            { skipDisplaceIfBinding, Ranks.HIGH }
        }
    },
    { 'tick',
        {
            freeIfHostIsDead
        }
    }
}

Binding.activate = 
    utils.checkApplyCycle('getBind', 'bind')

return Binding