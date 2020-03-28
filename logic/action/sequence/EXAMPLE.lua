
local stepFuncs = require "stepfuncs"
local AttackDigMoveAction = require "logic.action.actions.attackdigmove"
local None = require "logic.action.actions.none"
local SequenceUtils = require "modules.utils.sequence"
local Handlers = SequenceUtils.handlers


local turnToPlayerActionClass = 
    SequenceUtils.specialActionFromHandler("TurnToPlayer", Handlers.turnToPlayer)


local step1 = {
    action = turnToPlayerActionClass,
    success = {
        index = 2,
        chain = Chain.fromHandler(Handlers.checkOrthogonal)
    },
    fail = 1
}


local function infiniteArmorHandler(event)
    event.propagate = false
end

local function addInfiniteArmor(event)
    event.actor.chains.defence:addHandler(infiniteArmorHandler)
end

local function removeInfiniteArmor(event)
    event.actor.chains.defence:removeHandler(infiniteArmorHandler)
end


local step2 = {
    action = AttackDigMoveAction,
    success = {
        index = 3,
        chain = Chain.fromHandler(Handlers.checkNotMove)
    },
    fail = 2,
    enter = addInfiniteArmor,
    exit = removeInfiniteArmor
}


local step3 = {
    action = None,
    repet = 2
}

local steps = { step1, step2, step3 }

-- after that, decorate your entityClass like this:
-- Decorators.Sequential(entityClass, steps)
entityClass.sequenceSteps = steps
Decorators.Sequential.decorate(entityClass)