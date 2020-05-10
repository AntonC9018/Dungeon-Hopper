local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local decorate = require('logic.decorators.decorate')
local Decorators = require "logic.decorators.decorators"
local Attackableness = require 'logic.retouchers.attackableness'

local Dirt = class("Dirt", Entity)
Dirt.layer = Cell.Layers.wall

Decorators.Start(Wall)
decorate(Wall, Decorators.Diggable)
decorate(Wall, Decorators.WithHP)
decorate(Wall, Decorators.Attackable)
decorate(Wall, Decorators.Killable)
decorate(Wall, Decorators.DynamicStats)

Attackableness.no(Wall)

return Dirt