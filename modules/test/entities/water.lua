local Tile = require 'modules.test.base.tile'
local decorate = require('logic.decorators.decorate')
local Decorators = require 'logic.decorators.decorators' 
local Stucking = require 'modules.test.decorators.stucking'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 
local utils = require 'modules.test.base.utils'


local WaterTile = class("WaterTile", Tile)


Decorators.Start(WaterTile)
decorate(WaterTile, Decorators.Acting)
decorate(WaterTile, Decorators.Ticking)
decorate(WaterTile, Decorators.Attackable)
decorate(WaterTile, Decorators.WithHP)
decorate(WaterTile, Stucking)

utils.redirectActionToDecorator(WaterTile, 'Stucking')

local Algos = require 'logic.retouchers.algos'
Algos.simple(WaterTile)

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