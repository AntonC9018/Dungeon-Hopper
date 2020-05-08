local Entity = require "logic.base.entity"
local Cell = require "world.cell"

local EnvObject = class("EnvObject", Entity)

EnvObject.layer = Cell.Layers.real

return EnvObject