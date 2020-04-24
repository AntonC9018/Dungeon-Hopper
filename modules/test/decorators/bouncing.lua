local Decorator = require 'logic.decorators.decorators'
local utils = require 'logic.decorators.utils'
local Bounce = require 'logic.action.effects.bounce'

-- Define our custom decorator
local Bouncing = class("Bouncing", Decorator)


-- define the handlers for the chains
local function setBase(event)
    event.action.bounce = 
        Bounce(event.actor.baseModifiers.bounce)
end

local function getTarget(event)
    local actor = event.actor
    local entity = actor.world.grid:getRealAt(actor.pos)
    if entity == nil then
        event.propagate = false
    else
        event.target = entity
    end
end

local function checkAlreadyBounced(event)
    -- if hasn't just pushed the same thing
    -- this way we prevent infinite loops
    event.propagate = nextTrap.justBounced ~= event.target
end

local function bounceTarget(event)
    local bounceEvent = event.target:beBounced(event.action)
    if 
        bounceEvent ~= nil
    then
        event.bounceEvent = bounceEvent
        event.actor.justBounced = entity  
    else
        event.propagate = false
    end
end

local function changeState(event)
    event.actor.state = State.PRESSED
end

local function activateNextBounce(event)
    local displaceEvent = event.bounceEvent.displaceEvent

    if displaceEvent ~= nil then
        local oldPos = event.actor.pos
        local newPos = event.target.pos
        if 
            oldPos.x ~= newPos.x 
            or oldPos.y ~= newPos.y
        then
            local nextTrap = 
                event.actor.world.grid:getTrapAt(newPos)

            nextTrap:executeAction()
        end
    end
end

Bouncing.affectedChains = {
    { 'getBounce', 
        { 
            setBase, 
            getTarget, 
            checkAlreadyBounced 
        } 
    },
    { 'bounce', 
        { 
            changeState,
            bounceTarget, 
            utils.regChangeFunc(Changes.Bounce), 
            activateNextBounce 
        } 
    }
}

return Bouncing