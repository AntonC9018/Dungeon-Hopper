local funcs = require "funcs" 
local function getBase(event)
    event.attack = Attack(event.actor.baseStats.attack)
    event.status = Amounts(event.actor.baseStats.status)
    event.push = Push(event.actor.baseStats.push)
    
end

local function getTargets(event)
    local targets = event.actor.world:getTargets(event.actor, event.action)
    
    if 
        targets == nil
        or targets[1] == nil
    then
        event.propagate = false    
    else
        event.targets = targets
    end

    
end

local function applyAttack(event)
    local events = event.actor.world:doAttack(event.actor, event.attack)
    event.attackEvents = events
    
end

local function applyPush(event)
    local events = event.actor.world:doPush(event.targets, event.push)
    event.pushEvents = events
    
end

local function applyStatus(event)
    local events = event.actor.world:doStatus(event.targets, event.status)
    event.statusEvents = events
    
end


local Attacking = function(entityClass)
    local template = entityClass.chainTemplate

    template:addChain("getAttack")
    template:addHandler("getAttack", setBase)

    template:addChain("attack")
    tamplate:addHandler("attack", getTargets)
    template:addHandler("attack", applyAttack)
    template:addHandler("attack", applyPush)
    template:addHandler("attack", applyStatus)

    entityClass.executeAttack = funcs.checkApplyCycle("getAttack", "attack")

    table.insert(entityClass.decorators, Attacking)
end

return Attacking