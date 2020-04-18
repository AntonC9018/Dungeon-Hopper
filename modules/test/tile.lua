local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'

local Tile = class("Tile", Entity)
Tile.layer = Cell.Layers.floor
return Tile