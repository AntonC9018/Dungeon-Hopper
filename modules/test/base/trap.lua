local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local State = require 'modules.test.enums.pressed'
local Decorators = require 'logic.decorators.decorators'
local decorate = require 'logic.decorators.decorate'
local Retouchers = require 'logic.retouchers.all'
local retouch = require('logic.retouchers.utils').retouch

-- Class definition
local Trap = class('Trap', Entity)

Trap.layer = Cell.Layers.trap
Trap.state = State.UNPRESSED

Decorators.Start(Trap)
decorate(Trap, Decorators.WithHP)
decorate(Trap, Decorators.Ticking)
decorate(Trap, Decorators.Attackable)
decorate(Trap, Decorators.Acting)
decorate(Trap, Decorators.DynamicStats)
-- use the player algo
Retouchers.Algos.player(Trap)
Retouchers.Attackableness.no(Trap)

return Trap