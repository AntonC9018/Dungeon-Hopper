local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Decorator = require 'logic.decorators.decorator'
local Dig = require 'logic.action.effects.dig'


local Digging = class('Digging', Decorator)


local function setBase(event)
    event.action.dig = event.actor:getStat(StatTypes.Dig)
end

local function getTargets(event)
    local targets = event.actor:getDigTargets(event.action)    
    event.targets = targets
end

local function applyDig(event)
    local events = event.actor.world:doDig(event.targets, event.action)
    event.digEvents = events
end


Digging.affectedChains = {
    { "getDig", { setBase, getTargets } },
    { "dig", { applyDig, utils.regChangeFunc(Changes.Digs) } }
}


Digging.activate = 
    utils.checkApplyCycle("getDig", "dig")

return Digging