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

local Combos = require 'modules.test.decorators.combos'
Combos.Wall(Dirt)

return Dirt