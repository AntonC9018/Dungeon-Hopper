local utils = require "logic.decorators.utils" 
local Changes = require 'render.changes'

local Decorator = require 'logic.decorators.decorator'
local Diggable = class('Diggable', Decorator)

local function checkPower(event)
    local dig = event.action.dig
    if event.actor.baseModifiers.resistance.dig > dig.power then
        dig.damage = 0  
    end
end

-- TODO: fully implement
local function takeDigDamage(event)
    event.actor:takeDamage(event.action.dig.damage)    
end


Diggable.affectedChains =
    { 
        { "checkDig", { checkPower } },
        { "beDug", { takeDigDamage, utils.die, utils.regChangeFunc(Changes.Dug) } }
    }

Diggable.activate =
    utils.checkApplyCycle("checkDig", "beDug")
    

return Diggable
