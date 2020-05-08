local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local State = require 'modules.test.enums.pressed'

-- Class definition
local Trap = class("Trap", Entity)

Trap.layer = Cell.Layers.trap
Trap.state = State.UNPRESSED

return Trap