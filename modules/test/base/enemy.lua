local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local decorate = require('logic.decorators.decorate')
local Decorators = require "logic.decorators.decorators"
local Retouchers = require 'logic.retouchers.all'
local Attackableness = require 'logic.enums.attackableness'

local BasicEnemy = class("BasicEnemy", Entity)

BasicEnemy.layer = Cell.Layers.real

Decorators.Start(Enemy)
decorate(Enemy, Decorators.Acting)
decorate(Enemy, Decorators.Sequential)
decorate(Enemy, Decorators.Killable)
decorate(Enemy, Decorators.Ticking)
decorate(Enemy, Decorators.Attackable)
decorate(Enemy, Decorators.Attacking)
decorate(Enemy, Decorators.Moving)
decorate(Enemy, Decorators.Pushable)
decorate(Enemy, Decorators.Statused)
decorate(Enemy, Decorators.WithHP)
decorate(Enemy, Decorators.Displaceable)
decorate(Enemy, Decorators.DynamicStats)
Retouchers.Algos.general(Enemy)

return BasicEnemy