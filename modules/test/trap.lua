local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local decorate = require ('logic.decorators.decorator').decorate
local Decorators = require 'logic.decorators.decorators'
local Decorator = require 'logic.decorators.decorators'
local Changes = require 'render.changes'
local utils = require 'logic.decorators.utils'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 

-- Class definition
local Trap = class("Trap", Entity)

Trap.layer = Cell.Layers.traps

local State = {
    PRESSED = 0,
    UNPRESSED = 1
}

Trap.state = UNPRESSED


-- Define our custom decorator
local Bouncing = class("Bouncing", Decorator)

-- define the handlers for the chains
local function setBase(event)
    event.action.bounce = 
        event.actor.baseModifiers.bounce
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

local function bounceTarget(event)
    local bounce = event.action.bounce
    if 
        bounce.power > 
        event.target.baseModifiers.resistance.bounce or 0 
    then
        local move = bounce:toMove()
        local entity = event.target

        -- save the displace event
        event.displaceEvent = entity:displace(move) 
        event.actor.justBounced = entity  
    else
        event.propagate = false
    end
end

local function changeState(event)
    event.actor.state = State.PRESSED
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

            -- if hasn't just pushed the same thing
            -- this way we prevent infinite loops
            if nextTrap.justBounced ~= event.target then
                nextTrap:executeAction()
            end
        end
    end
end

Bouncing.affectedChains = {
    { 'getBounce', { setBase, getTarget } },
    { 'bounce', 
        { 
            bounceTarget, 
            changeState,
            utils.regChangeFunc(Changes.Bounce), 
            activateNextBounce 
        } 
    }
}

-- Decorate
Decorators.Start(Trap)
decorate(Trap, Decorators.WithHP)
decorate(Trap, Decorators.Ticking)
decorate(Trap, Decorators.Explodable)
decorate(Trap, Decorators.Acting)
-- apply our custom decorator
decorate(Trap, Bouncing)

Trap.chainTemplate:addHandler(
    'action', 
    -- use the player algo, as it just does the action, which is what we need
    require 'logic.action.algorithms.player'
)

local function tickBounce(event)
    local actor = event.actor
    
    actor.justBounced = nil

    local nextState =
        actor.world.grid:getRealAt(actor.pos) ~= nil
        and State.PRESSED
        or State.UNPRESSED
    
    if actor.state ~= nextState then
        actor.world:pushChange(actor, Changes.JustState)
    end
end

-- TODO: this should probably be an emitter handler instead 
Trap.chainTemplate:addHandler(
    "tick",
    tickBounce
)


-- define our custom action that calls the new decorator's activation
local BounceAction = Action.fromHandlers(
    'BounceAction',
    { handlerUtils.applyHandler('executeBounce') }
)

-- define a new method that calls the new decorator
function Trap:executeBounce(action)
    self.decorators.Bouncing:activate(self, action)
end

-- override calculateAction. Return our custom action
function Trap:calculateAction()
    local action = BounceAction()
    -- set the orientation right away since it won't change
    action.direction = self.orientation
end


return Trap