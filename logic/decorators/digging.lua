local utils = require "@decorators.utils" 
local Changes = require "render.changes"
local Decorator = require '@decorators.decorator'
local Dig = require '@action.effects.dig'
local Do = require '@interactors.do'

local Digging = class('Digging', Decorator)


local function setBase(event)
    event.action.dig = event.actor:getStat(StatTypes.Dig)
end

local function getTargets(event)
    local targets = event.actor:getDigTargets(event.action)
    event.targets = targets
end

local function applyDig(event)
    local events = Do.dig(event.targets, event.action)
    event.digEvents = events
end


Digging.affectedChains = {
    { "getDig", 
        { 
            { setBase, Ranks.HIGH }, 
            getTargets 
        } 
    },
    { "dig", 
        { 
            applyDig, 
            utils.regChangeFunc(Changes.Digs) 
        } 
    }
}


Digging.activate = 
    utils.checkApplyCycle("getDig", "dig")

return Digging