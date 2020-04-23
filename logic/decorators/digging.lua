local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"

local Decorator = require 'logic.decorators.decorator'
local Dig = require 'logic.action.effects.dig'

local Attacking = class('Attacking', Decorator)

local function setBase(event)
    event.action.dig = Dig(event.actor.baseModifiers.dig) 
end

local function getTargets(event)
    local targets = event.actor:getDigTargets(event.action)    
    event.targets = targets
end

local function applyDig(event)
    local events = event.actor.world:doDig(event.targets, event.action)
    event.digEvents = events 
end

Attacking.affectedChains = {
    { "getDig", { setBase, getTargets } },
    { "dig", { applyDig, utils.regChangeFunc(Changes.Digs) } }
}


Attacking.activate = 
    utils.checkApplyCycle("getDig", "dig")

return Attacking