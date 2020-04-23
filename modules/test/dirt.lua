local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'

local Dirt = class("Dirt", Entity)
Dirt.layer = Cell.Layers.wall

Dirt.baseModifiers = {
    hp = 1,
    resistance = {
        dig = 0
    }
}

local decorate = require ("logic.decorators.decorator").decorate
local Decorators = require "logic.decorators.decorators"

Decorators.Start(Dirt)
decorate(Dirt, Decorators.Diggable)
decorate(Dirt, Decorators.WithHP)
decorate(Dirt, Decorators.Explodable)
decorate(Dirt, Decorators.Killable)

return Dirt