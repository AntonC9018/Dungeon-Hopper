local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"

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

-- TODO: this should have medium priority so that
-- it is possible to first apply all piercing and stuff
-- and then check if able to attack.
-- For example take the ghost that CAN BE ATTACKED only if your level of 
-- piercing is significantly high. In contast, an enemy with piercing 
-- protection, e.g. shielded enemies are ABLE TO BE ATTACKED, that is, 
-- if you try to attack them, they'll let you, but there'll be no damage.
-- Ghosts, however, won't allow you to attack them if you wouldn't pierce 
-- the high protection level. This way, ghosts will work by adding
-- a handler onto their `Attackable.attackableness` chain, which is traversed
-- when this function (getTargets) is called. That function would compare
-- the piercing levels and tell the system the ghost can't be attacked
-- if your piercing is not high enough. If there were no way to add 
-- functions before this one, the ghost could never know the real 
-- piercing levels.
local function getTargets(event)
    local targets = event.actor:getTargets(event.action)    
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
    { "attack", { applyAttack, applyPush, applyStatus, utils.regChangeFunc(Changes.Hits) } }
}


Attacking.activate = 
    utils.checkApplyCycle("getAttack", "attack")

return Attacking