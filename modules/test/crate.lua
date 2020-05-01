local Entity = require "logic.base.entity"
local Cell = require "world.cell"

local Crate = class("Crate", Entity)

Crate.layer = Cell.Layers.real

Crate.baseModifiers = {
    hp = {
        amount = 1
    },
    resistance = {
        push = 0,
        pierce = 1
    }
}


local decorate = require ("logic.decorators.decorator").decorate
local Decorators = require "logic.decorators.decorators"

Decorators.Start(Crate)
decorate(Crate, Decorators.Attackable)
decorate(Crate, Decorators.Killable)
decorate(Crate, Decorators.Pushable)
decorate(Crate, Decorators.Displaceable)
decorate(Crate, Decorators.DynamicStats)
decorate(Crate, Decorators.Explodable)
decorate(Crate, Decorators.WithHP)
decorate(Crate, Decorators.Attackable)


local AttackablenessRetoucher = require 'logic.retouchers.attackableness'
local Attackableness = require 'logic.enums.attackableness'
AttackablenessRetoucher.constant(Crate, Attackableness.IF_NEXT_TO)

-- set our pierce to 0 when attacked if attack damage is greater than 3
local DAMAGE_THRESH = 3
local PIERCE = 0

local function pierceHandler(event)
    if event.attack.damage >= DAMAGE_THRESH then
        event.resistance:set('pierce', PIERCE)
    end
end


return Crate