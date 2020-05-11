local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local BasicEnemy = require 'modules.test.base.enemy'

local TestEnemy = class("TestEnemy", BasicEnemy)

-- Set up all decorators
Entity.copyChains(BasicEnemy, TestEnemy)

-- Set up sequence
local None = require "logic.action.actions.none"
local AttackMoveAction = require "logic.action.actions.attackmove"
local Handlers = require 'modules.utils.handlers'

local steps = {    
    { -- first step: skip the beat
        action = None,
        repet = 1
    },    
    { -- second step: try to attack, then try to move 
        action = AttackMoveAction,
        -- the movs function
        movs = require "logic.sequence.movs.adjacent",
        -- the exit function: turn to player
        exit = Handlers.turnToPlayer
    }
}

TestEnemy.sequenceSteps = steps


-- Retouch
local Skip = require 'logic.retouchers.skip'
Skip.noPlayer(TestEnemy)
Skip.blockedMove(TestEnemy)

local Bounce = require 'modules.test.retouchers.bounce'
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
        amount = 5
    }
}

return TestEnemy