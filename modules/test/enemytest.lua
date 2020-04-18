local Entity = require "logic.base.entity"
local Cell = require "world.cell"

local TestEnemy = class("TestEnemy", Entity)

-- Set up sequence
local None = require "logic.action.actions.none"
local HandlerUtils = require "logic.action.handlers.utils"
local Action = require "logic.action.action"
local Handlers = require("modules.utils.sequence").handlers

TestEnemy.layer = Cell.Layers.real

local step1 = {
    action = None
}

local step2 = {
    action = Action.fromHandlers(
        "TATM",
        {   
            -- try to attack
            HandlerUtils.checkApplyHandler(
                -- the check chain
                Chain({ Handlers.checkTargetIsPlayer }),
                -- the apply method on actor
                "executeAttack"
            ),
            -- try to move
            HandlerUtils.checkApplyHandler(
                -- the check chain
                Chain({ Handlers.checkIsFree }),
                -- the apply method on actor
                "executeMove"
            )
        }
    )
}


TestEnemy.sequenceSteps = { step1, step2 }

-- Set up movs
TestEnemy.getMovs = require "logic.action.dirs.basic"

-- Set up all decorators
local Combos = require "logic.decorators.combos"
Combos.BasicEnemy(TestEnemy)

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