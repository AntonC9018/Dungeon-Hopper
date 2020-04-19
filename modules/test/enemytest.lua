local Entity = require "logic.base.entity"
local Cell = require "world.cell"

local TestEnemy = class("TestEnemy", Entity)

TestEnemy.layer = Cell.Layers.real

-- Set up all decorators
local Combos = require "logic.decorators.combos"
Combos.BasicEnemy(TestEnemy)

-- Set up sequence
local None = require "logic.action.actions.none"
local HandlerUtils = require "logic.action.handlers.utils"
local Action = require "logic.action.action"
local Handlers = require "modules.utils.handlers"
local ActionHandlers = require "logic.action.handlers.basic"

local steps = {    
    { -- first step: skip the beat
        action = None
    },    
    { -- second step: try to attack, then try to move 
        action = 
            Action.fromHandlers( 
                -- name for the action
                "TATM",
                {   
                    -- try to attack
                    ActionHandlers.Attack,
                    -- try to move
                    ActionHandlers.Move
                },
                -- the movs function
                require "logic.action.movs.basic"
            )
    }
}


TestEnemy.sequenceSteps = steps


-- set up action checks
-- TODO: this probably should be refactored into a simpler method
TestEnemy.chainTemplate:addHandler(
    'getAttack', Handlers.checkTargetsHavePlayer
) 
TestEnemy.chainTemplate:addHandler(
    'getMove', Handlers.checkFreeMove
) 

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