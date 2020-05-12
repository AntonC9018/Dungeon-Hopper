local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local decorate = require('logic.decorators.decorate')
local Decorators = require "logic.decorators.decorators"
local Retouchers = require 'logic.retouchers.all'

local BasicEnemy = class("BasicEnemy", Entity)

BasicEnemy.layer = Cell.Layers.real

Decorators.Start(BasicEnemy)
decorate(BasicEnemy, Decorators.Acting)
decorate(BasicEnemy, Decorators.Sequential)
decorate(BasicEnemy, Decorators.Killable)
decorate(BasicEnemy, Decorators.Ticking)
decorate(BasicEnemy, Decorators.Attackable)
decorate(BasicEnemy, Decorators.Attacking)
decorate(BasicEnemy, Decorators.Moving)
decorate(BasicEnemy, Decorators.Pushable)
decorate(BasicEnemy, Decorators.Statused)
decorate(BasicEnemy, Decorators.WithHP)
decorate(BasicEnemy, Decorators.Displaceable)
decorate(BasicEnemy, Decorators.DynamicStats)
Retouchers.Algos.general(BasicEnemy)

return BasicEnemy