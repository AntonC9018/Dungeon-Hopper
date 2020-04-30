local Entity = require "logic.base.entity"
local Cell = require "world.cell"

local TestEnemy = class("TestEnemy", Entity)

TestEnemy.layer = Cell.Layers.real

-- Set up all decorators
local Combos = require "logic.decorators.combos"
Combos.BasicEnemy(TestEnemy)

-- Set up sequence
local None = require "logic.action.actions.none"
local AttackMoveAction = require "logic.action.actions.attackmove"
local Handlers = require "modules.utils.handlers"

local steps = {    
    { -- first step: skip the beat
        action = None
    }
    -- ,    
    -- { -- second step: try to attack, then try to move 
    --     action = AttackMoveAction,
    --     -- the movs function
    --     movs = require "logic.action.movs.basic"
    -- }
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

    hp = {
        amount = 5
    }
}

return TestEnemy