local Tile = require '.base.tile'
local Stucking = require '.decorators.stucking'
local Action = require '@action.action'
local handlerUtils = require '@action.handlers.utils' 
local utils = require '.base.utils'


local WaterTile = class("WaterTile", Tile)


Decorators.Start(WaterTile)
decorate(WaterTile, Decorators.Acting)
decorate(WaterTile, Decorators.Ticking)
decorate(WaterTile, Decorators.Attackable)
decorate(WaterTile, Decorators.WithHP)
decorate(WaterTile, Stucking)

utils.redirectActionToDecorator(WaterTile, 'Stucking')

Retouchers.Algos.simple(WaterTile)
Retouchers.Attackableness.no(WaterTile)

WaterTile.baseModifiers = {
    stuck = {
        power = 2
    },
    hp = {
        amount = 1
    }
}

return WaterTile