local Decorator = require '@decorators.decorator'
local utils = require '@decorators.utils'
local Changes = require 'render.changes'

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
    event.statusEvent = event.target:beStatused(event.action)
    print(event.target.statuses:get('bind'))
end


local function register(event)
    -- if bound were successful, the stat on entity is not 0
    local success = event.target.statuses:get('bind') ~= 0 

    -- set up the store of the status effect
    -- TODO: reconsider? improve? because this is not a great solution
    Mods.Test.Status.bind.tinker:setStore(event.target, event.actor)
    
    -- remove oneself from grid
    event.actor.world.grid:remove(event.actor)
    -- move to the player's position
    event.actor.pos = event.target.pos

    -- if the bind did get applied,
    if success then
        -- register that on the actor
        event.actor.didBind = true
        -- change state to 2
        event.actor.state = 2
        -- TODO: in some way increase health
        -- TODO: 
    else 
        -- for now just die
        event.actor:die()
    end
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
    { 'checkPush',
        {
            function(event) event.propagate = false end
        }
    }
}

Binding.activate = 
    utils.checkApplyCycle('getBind', 'bind')

return Binding