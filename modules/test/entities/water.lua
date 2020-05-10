local Tile = require 'modules.test.tile'
local decorate = require('logic.decorators.decorate')
local Decorators = require 'logic.decorators.decorators' 
local Stucking = require 'modules.test.decorators.stucking'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 


local WaterTile = class("WaterTile", Tile)


Decorators.Start(WaterTile)
decorate(WaterTile, Decorators.Acting)
decorate(WaterTile, Decorators.Ticking)
decorate(WaterTile, Decorators.Attackable)
decorate(WaterTile, Decorators.WithHP)
decorate(WaterTile, Stucking)

-- define our custom action that calls the new decorator's activation
local StuckAction = Action.fromHandlers(
    'StuckAction',
    { handlerUtils.activateDecorator('Stucking') }
)

-- override calculateAction. Return our custom action
function WaterTile:calculateAction()
    self.nextAction = StuckAction()
end

local Algos = require 'logic.retouchers.algos'
Algos.player(WaterTile)

local Attackableness = require 'logic.retouchers.attackableness'
Attackableness.no(WaterTile)

WaterTile.baseModifiers = {
    stuck = {
        power = 2
    },
    hp = {
        amount = 1
    }
}

return WaterTile