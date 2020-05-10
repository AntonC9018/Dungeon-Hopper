local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local decorate = require('logic.decorators.decorate')
local Decorators = require "logic.decorators.decorators"
local Retouchers = require 'logic.retouchers.all'
local Attackableness = require 'logic.enums.attackableness'

local EnvObject = class("EnvObject", Entity)

EnvObject.layer = Cell.Layers.real

Decorators.Start(EnvObject)
decorate(EnvObject, Decorators.Attackable)
decorate(EnvObject, Decorators.Killable)
decorate(EnvObject, Decorators.Pushable)
decorate(EnvObject, Decorators.Displaceable)
decorate(EnvObject, Decorators.DynamicStats)
decorate(EnvObject, Decorators.WithHP)

Retouchers.Attackableness.constant(EnvObject, Attackableness.IF_NEXT_TO)

return EnvObject