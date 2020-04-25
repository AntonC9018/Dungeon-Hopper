local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Bounce = require 'logic.action.effects.bounce'
local Changes = require 'render.changes'

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
    event.propagate = event.actor.justBounced ~= event.target
end

local function bounceTarget(event)
    local bounceEvent = event.target:beBounced(event.action)
    if 
        bounceEvent ~= nil
    then
        event.bounceEvent = bounceEvent
        event.actor.justBounced = event.target  
    else
        event.propagate = false
    end
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

            if nextTrap ~= nil then
                nextTrap:executeAction()
            end
        end
    end
end

local function resetJustBounced(event)
    event.actor.justBounced = nil
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
            bounceTarget, 
            utils.regChangeFunc(Changes.Bounce), 
            activateNextBounce 
        } 
    },
    { 'tick', { resetJustBounced } }
}

Bouncing.activate = 
    utils.checkApplyCycle('getBounce', 'bounce')

return Bouncing