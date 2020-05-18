local Entity = require "@base.entity"
local Cell = require "world.cell"
local BasicEnemy = require '.base.enemy'

local TestEnemy = class("TestEnemy", BasicEnemy)

-- Set up all decorators
copyChains(BasicEnemy, TestEnemy)

-- Set up sequence
local None = require "@action.actions.none"
local AttackMoveAction = require "@action.actions.attackmove"
local Handlers = require 'modules.utils.handlers'

local steps = {    
    { -- first step: skip the beat
        action = None,
        repet = 1
    },    
    { -- second step: try to attack, then try to move 
        action = AttackMoveAction,
        -- the movs function
        movs = require "@sequence.movs.basic",
        fail = 2,
        -- the exit function: turn to player
        exit = Handlers.turnToPlayer
    }
}

TestEnemy.sequenceSteps = steps


-- Retouch
Retouchers.Skip.noPlayer(TestEnemy)
Retouchers.Skip.blockedMove(TestEnemy)

local Bounce = require '.retouchers.bounce'
Bounce.redoAttackAfter(TestEnemy)
Bounce.redirectAfter(TestEnemy)


TestEnemy.baseModifiers = {

    attack = {
        damage = 1,
        pierce = 1
    },

    push = {
        power = 2
    },

    resistance = {
        armor = 0,
        push = 0,
        pierce = 1
    },

    hp = {
        amount = 2
    }
}

return TestEnemy