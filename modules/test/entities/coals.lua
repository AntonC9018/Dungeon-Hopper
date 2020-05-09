local Tile = require 'modules.test.tile'
local decorate = require('logic.decorators.decorator').decorate
local Decorators = require 'logic.decorators.decorators'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 

local Coals = class("Coals", Tile)

Decorators.Start(Coals)
decorate(Coals, Decorators.Acting)
decorate(Coals, Decorators.Attacking)
decorate(Coals, Decorators.Ticking)

-- define our custom action that calls the new decorator's activation
local CoalsAction = Action.fromHandlers(
    'CoalsAction',
    { handlerUtils.applyHandler('executeBurn') }
)

-- override calculateAction. Return our custom action
function Coals:calculateAction()
    self.nextAction = CoalsAction()
end

-- TODO: refactor into a decorator
function Coals:executeBurn(action)
    local real = self.world.grid:getRealAt(self.pos)
    if self.savedTarget == real then
        return self.executeAttack(action, { real })
    else
        self.savedTarget = real
    end
    return { success = true }
end

local Algos = require 'logic.retouchers.algos'
Algos.player(Coals)

Coals.baseModifiers = {
}

return Coals