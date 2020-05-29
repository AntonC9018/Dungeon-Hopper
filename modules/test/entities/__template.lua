local Entity = require "@base.entity"
local Cell = require "world.cell"

local FooBar = class("FooBar", Entity)

-- select layer
FooBar.layer = Cell.Layers.real

-- select base stats
FooBar.baseModifiers = {
    attack = {
        damage = 1,
        pierce = 1
    },
    push = {
        power = 0,
        distance = 1
    },
    dig = {
        power = 0,
        damage = 0    
    },
    move = {
        distance = 1,
        through = false
    },
    resistance = {
        armor = 0,
        pierce = 1,
        maxDamage = math.huge,
        minDamage = 1,
        push = 1,
        dig = 1
    },
    hp = {
        amount = 1
    }   
}


-- make a sequence, if you are coding an enemy
local None = require "@action.actions.none"
local AttackMoveAction = require "@action.actions.attackmove"
local Handlers = require 'modules.utils.handlers'

FooBar.sequenceSteps = {    
    { -- first step: skip the beat
        action = None
    }
    ,    
    { -- second step: try to attack, then try to move 
        action = AttackMoveAction,
        -- the movs function
        movs = require "@sequence.movs.adjacent",
        -- the exit function: turn to player
        exit = Handlers.turnToPlayer
    }
}


-- apply decorators
local decorate = require('@decorators.decorate')
local Decorators = require "@decorators.decorators"

Decorators.Start(FooBar)
Decorators.General(FooBar)
decorate(FooBar, Decorators.Attackable)
decorate(FooBar, Decorators.Killable)
decorate(FooBar, Decorators.Pushable)
decorate(FooBar, Decorators.Displaceable)
decorate(FooBar, Decorators.DynamicStats)
decorate(FooBar, Decorators.WithHP)
-- ...


-- alternatively, use a combo
-- local Combos = require '@decorators.combos'
-- Combos.BasicEnemy(FooBar)
-- or
-- Combos.Player(FooBar)


-- apply retouchers
local Retouchers = require '@retouchers.all'
Retouchers.skip.emptyAttack(FooBar)
Retouchers.reorient.onAttack(FooBar)
-- ...


return FooBar