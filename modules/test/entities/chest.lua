local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local Decorators = require 'logic.decorators.decorators'
local decorate = require 'logic.decorators.decorate'
local Retouchers = require 'logic.retouchers.all'
local Attackableness = require 'logic.enums.attackableness'

-- Class definition
local Chest = class('Chest', Entity)

Chest.layer = Cell.Layers.real

Decorators.Start(Chest)
decorate(Chest, Decorators.Killable)
decorate(Chest, Decorators.Interactable)
-- Retouchers.Attackableness.constant(Chest, Attackableness.IF_NEXT_TO)

return Chest