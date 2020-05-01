
local AttackDigMove = require "logic.action.actions.attackdigmove"
local None = require "logic.action.actions.none"
local Handlers = require "modules.utils.handlers"
local Action = require "logic.action"

-- create out entity class
local Entity = require "logic.base.entity"
local EntityClass = class(Entity)

-- define some custom functions
local function infiniteArmorHandler(event)
    event.propagate = false
end

local function addInfiniteArmor(event)
    event.actor.chains.defence:addHandler(infiniteArmorHandler)
end

local function removeInfiniteArmor(event)
    event.actor.chains.defence:removeHandler(infiniteArmorHandler)
end

-- define sequence steps
local step1 = {
    action =
        -- create a new action from the list of handlers 
        Action.fromHandlers(
            -- the name of the action
            "TurnToPlayer", 
            { 
                -- use a handler, predefined or coded on your own
                Handlers.turnToPlayer
            }
        ), 
    checkSuccess = 
        -- we've gotta chuck a checkOrthogonal function here
        -- to check whether the armadillo and the player
        -- are on one line / column
        -- for this, we create a custom chain on which we hang that function
        -- create a chain that consists of one handler
        chain: Chain({ Handlers.checkOrthogonal }),
     -- the next step index
    success = 2,
    -- in case this fails, e.g. we're frozen, remain at the 1st step
    fail = 1
}

local step2 = {
    -- this one is simpler
    action = AttackDigMove,
    -- for success we again need a custom chain
    checkSuccess = Chain({ Handlers.checkNotMove }),
    -- in case of moving, do the next step
    success = 3,
    -- in case frozen, keep rolling
    fail = 2,
    -- also, we're invincible while rolling
    enter = addInfiniteArmor,
    -- and we shouldn't be while not rolling
    exit = removeInfiniteArmor,
    -- and add the movs function
    movs = followOrientation
}

step3 = {
    action = None,
    repet = 2, -- repeat this step 2 times before going to the next one
    success = 1 -- this and the fail can be omitted, as the sequence loops by default
} 

-- save them on our class
EntityClass.sequenceSteps = { step1, step2, step3 }

-- after that, decorate your entityClass like this:
local decorate = require("logic.decorators.decorator").decorate
local Sequential = require "logic.decorators.sequential"
decorate(EntityClass, Sequential)

-- or, using a combo
local Combos = require "logic.decorators.combos"
Combos.BasicEnemy(EntityClass)

-- also, some basic check handlers have to be added to prevent attacking empty spaces
-- these are to be covered later and are thus ignored for now