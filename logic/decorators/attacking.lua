local utils = require "logic.decorators.utils" 

local Decorator = require 'logic.decorators.decorator'
local Stats = require 'logic.stats.stats' 
local Attack = require 'logic.action.effects.attack'
local Push = require 'logic.action.effects.push'

local Attacking = class('Attacking', Decorator)

local function setBase(event)
    event.action.attack = Attack(event.actor.baseModifiers.attack)
    event.action.status = Stats.fromTable(event.actor.baseModifiers.status)
    event.action.push = Push(event.actor.baseModifiers.push)  
end

local function getTargets(event)
    local targets = event.actor.world:getTargets(event.actor, event.action)    
    event.targets = targets
end

local function applyAttack(event)
    local events = event.actor.world:doAttack(event.targets, event.action)
    event.attackEvents = events
end

local function applyPush(event)
    local events = event.actor.world:doPush(event.targets, event.action)
    event.pushEvents = events    
end

local function applyStatus(event)
    local events = event.actor.world:doStatus(event.targets, event.action)
    event.statusEvents = events    
end

Attacking.affectedChains = {
    { "getAttack", { setBase, getTargets } },
    { "attack", { applyAttack, applyPush, applyStatus } }
}


Attacking.activate = 
    utils.checkApplyCycle("getAttack", "attack")

return Attacking