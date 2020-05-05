local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'

local Dirt = class("Dirt", Entity)
Dirt.layer = Cell.Layers.wall

Dirt.baseModifiers = {
    hp = {
        amount = 1
    },
    resistance = {
        dig = 0
    }
}

local decorate = require ("logic.decorators.decorator").decorate
local Decorators = require "logic.decorators.decorators"

Decorators.Start(Dirt)
decorate(Dirt, Decorators.Diggable)
decorate(Dirt, Decorators.WithHP)
decorate(Dirt, Decorators.Attackable)
decorate(Dirt, Decorators.Killable)
decorate(Dirt, Decorators.DynamicStats)

local Attackableness = require 'logic.retouchers.attackableness'
Attackableness.no(Dirt)

return Dirt