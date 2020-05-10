local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Changes = require 'render.changes'
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local DynamicStats = require 'logic.decorators.dynamicstats'
local HowToReturn = require 'logic.decorators.stats.howtoreturn'
local Attackable = require 'logic.decorators.attackable'

Attackable.registerAttackSource('Bounce')

-- Define our custom decorator
local Bouncing = class('Bouncing', Decorator)


-- define the handlers for the chains
local function setBase(event)
    event.action.push = event.actor:getStat(StatTypes.Push)
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
    event.pushEvent = event.target:bePushed(event.action)
    event.actor.justBounced = event.target

    event.propagate = event.pushEvent.success
end


local function activateNextBounce(event)
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