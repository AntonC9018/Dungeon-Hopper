local utils = require "utils" 

local Decorator = require 'decorator'
local Attacking = class('Attacking', Decorator)

local function getBase(event)
    event.attack = Attack(event.actor.baseModifiers.attack)
    event.status = Stats.fromTable(event.actor.baseModifiers.status)
    event.push = Push(event.actor.baseModifiers.push)    
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

Attacking.affectedChains = {
    { "getAttack", { setBase } },
    { "attack", { getTargets, applyAttack, applyPush, applyStatus } }
}


Attacking.activate = 
    utils.checkApplyCycle("getAttack", "attack")

return Attacking