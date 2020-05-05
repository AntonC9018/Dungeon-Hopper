local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Bounce = require 'modules.test.effects.bounce'
local Changes = require 'render.changes'
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local DynamicStats = require 'logic.decorators.dynamicstats'
local HowToReturn = require 'logic.decorators.stats.howtoreturn'

DynamicStats.registerStat(
    'BounceRes',
    { -- stuck res
        'resistance',
        {
            'bounce', 1
        }
    },
    HowToReturn.NUMBER
)

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
    local resistance = event.target:getStat(StatTypes.BounceRes)
    local bounce = event.action.bounce
    
    if 
        bounce.power > resistance
    then
        event.displaceEvent = event.target:displace( 
            bounce:toMove(event.action.direction) 
        )
        event.target.world:registerChange(event.target, Changes.Push)
        event.actor.justBounced = event.target  
    else
        event.propagate = false
    end
end


local function activateNextBounce(event)

    if event.displaceEvent ~= nil then
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