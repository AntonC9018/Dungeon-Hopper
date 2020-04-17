local Entity = require "logic.base.entity"
local Decorators = require "logic.decorators.decorators"
local decorate = require ('logic.decorators.decorator').decorate
local Cell = require "world.cell"

local TestEnemy = class("TestEnemy", Entity)

-- Set up sequence
local AttackMoveAction = require "logic.action.actions.attackmove"
local None = require "logic.action.actions.none"

local step1 = {
    action = None
}

local step2 = {
    action = AttackMoveAction
}

TestEnemy.sequenceSteps = { step1, step2 }

-- Set up movs
TestEnemy.getMovs = require "logic.action.dirs.basic"

TestEnemy.layer = Cell.Layers.real

-- Set up all decorators
Decorators.Start(TestEnemy)
Decorators.General(TestEnemy)
decorate(TestEnemy, Decorators.Attackable)
decorate(TestEnemy, Decorators.Attacking)
decorate(TestEnemy, Decorators.Bumping)
decorate(TestEnemy, Decorators.Explodable)
decorate(TestEnemy, Decorators.Moving)
decorate(TestEnemy, Decorators.Pushable)
decorate(TestEnemy, Decorators.Statused)
-- decorate(TestEnemy, Decorators.Ticking)
decorate(TestEnemy, Decorators.WithHP)

TestEnemy.baseModifiers = {

    attack = {
        damage = 1,
        pierce = 1
    },

    move = {
        distance = 1
    },

    push = {
        distance = 1,
        power = 1
    },

    resistance = {
        armor = 0,
        maxDamage = math.huge,
        push = 0,
        pierce = 1
    },

    hp = 2
}

return TestEnemy