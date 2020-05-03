local Tile = require 'modules.test.tile'
local decorate = require('logic.decorators.decorator').decorate
local Decorators = require 'logic.decorators.decorators' 
local Stucking = require 'modules.test.decorators.stucking'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 


local WaterTile = class("WaterTile", Tile)


Decorators.Start(WaterTile)
decorate(WaterTile, Decorators.Acting)
decorate(WaterTile, Decorators.Ticking)
decorate(WaterTile, Decorators.Explodable)
decorate(WaterTile, Decorators.WithHP)
decorate(WaterTile, Stucking)

-- define our custom action that calls the new decorator's activation
local StuckAction = Action.fromHandlers(
    'StuckAction',
    { handlerUtils.applyHandler('executeStuck') }
)

-- define a new method that calls the new decorator
function WaterTile:executeStuck(action)
    return self.decorators.Stucking:activate(self, action)
end

-- override calculateAction. Return our custom action
function WaterTile:calculateAction()
    self.nextAction = StuckAction()
end

local Algos = require 'logic.retouchers.algos'
Algos.player(WaterTile)

WaterTile.baseModifiers = {
    stuck = {
        power = 2
    },
    hp = {
        amount = 1
    }
}

return WaterTile