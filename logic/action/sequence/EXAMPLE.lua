
local Chain = require "lib.chains.chain"
local stepFuncs = require "stepfuncs"
local Special = require "logic.action.actions.special"
local AttackDigMoveAction = require "logic.action.actions.attackdigmove"
local None = require "logic.action.actions.none"


local function specialAction(name, handler)
    local chain = Chain()
    chain:addHandler(handler)
    local specialClass = class(name, Special)
    specialClass.chain = chain
    return specialClass
end


local function turnToPlayer(event)

    local world = event.actor.world
    local coord = event.actor.pos
    local player = world:getClosestPlayer()

    local difference = player.pos - coord
    local x, y = difference:abs():comps()

    if x > y then
        local newX = sign(difference.x)
        event.actor.orientation = Vec(newX, 0)
    else
        local newY = sign(difference.y)
        event.actor.orientation = Vec(0, newY)
    end

end


local turnToPlayerActionClass = specialAction("TurnToPlayer", turnToPlayer)


local function checkOrthogonal(event)

    local world = event.actor.world
    local coord = event.actor.pos
    local player = world:getClosestPlayer()

    event.propagate = 
        coord.x == player.x or coord.y == player.y

end


local step1 = {
    action = turnToPlayerActionClass,
    success = {
        index = 2,
        chain = Chain.fromHandler(checkOrthogonal)
    },
    failure = 1
}


local function checkNotMove(event)
    event.propagate = not event.actor:didMove()
end

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
        chain = Chain.fromHandler(checkNotMove)
    },
    failed = 2,
    enter = addInfiniteArmor,
    exit = removeInfiniteArmor
}


local step3 = {
    action = None,
    repet = 2
}

local steps = { step1, step2, step3 }

-- after that, decorate your entityClass like this:
Decorators.Sequential(entityClass, steps)