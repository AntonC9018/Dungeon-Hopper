local utils = require "logic.decorators.utils" 
local Changes = require 'render.changes'

local Decorator = require 'logic.decorators.decorator'
local Attackable = class('Attackable', Decorator)

local function checkPower(event)
    local dig = event.action.dig
    if dig.pierce > event.actor.baseModifiers.pierce then
        dig.damage = 0  
    end
end

-- TODO: fully implement
local function takeDigDamage(event)
    event.actor:takeDamage(event.action.dig.damage)    
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end
end


Attackable.affectedChains =
    { 
        { "checkDig", { checkPower } },
        { "beDug", { takeDigDamage, die, utils.regChangeFunc(Changes.Dug) } }
    }

Attackable.activate =
    utils.checkApplyCycle("checkDig", "beDug")
    

return Attackable
