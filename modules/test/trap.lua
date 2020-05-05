local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local decorate = require ('logic.decorators.decorator').decorate
local Decorators = require 'logic.decorators.decorators'
local Bouncing = require 'modules.test.decorators.bouncing'
local Changes = require 'render.changes'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 
local retouch = require('logic.retouchers.utils').retouch

-- Class definition
local Trap = class("Trap", Entity)

Trap.layer = Cell.Layers.trap

local State = {
    PRESSED = 0,
    UNPRESSED = 1
}

Trap.state = State.UNPRESSED

-- Decorate
Decorators.Start(Trap)
decorate(Trap, Decorators.WithHP)
decorate(Trap, Decorators.Ticking)
decorate(Trap, Decorators.Explodable)
decorate(Trap, Decorators.Acting)
-- apply our custom decorator
decorate(Trap, Bouncing)


local function changeState(event)
    event.actor.state = State.PRESSED
end

-- be physically pushed after the player steps on this
retouch(Trap, 'bounce', changeState)


-- use the player algo
local Algos = require 'logic.retouchers.algos'
Algos.player(Trap)


local function tickTrap(event)
    local actor = event.actor
    
    local nextState =
    actor.world.grid:getRealAt(actor.pos) ~= nil
    and State.PRESSED
    or State.UNPRESSED
    
    if actor.state ~= nextState then
        actor.world:registerChange(actor, Changes.JustState)
    end
end

-- get unpushed / pushed
retouch(Trap, 'tick', tickTrap)


-- define our custom action that calls the new decorator's activation
local BounceAction = Action.fromHandlers(
    'BounceAction',
    handlerUtils.applyHandler('executeBounce')
)

-- define a new method that calls the new decorator
function Trap:executeBounce(action)
    return self.decorators.Bouncing:activate(self, action)
end

-- override calculateAction. Return our custom action
function Trap:calculateAction()
    local action = BounceAction()
    -- set the orientation right away since it won't change
    action.direction = self.orientation
    self.nextAction = action
end


Trap.baseModifiers = {
    bounce = {
        power = 2,
        distance = 1
    },
    hp = {
        amount = 1
    }
}


return Trap