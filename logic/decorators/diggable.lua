local utils = require "logic.decorators.utils" 
local Changes = require 'render.changes'
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Decorator = require 'logic.decorators.decorator'
local Diggable = class('Diggable', Decorator)

local function setBase(event)
    event.resistance = event.actor:getStat(StatTypes.DigRes)
end

local function checkPower(event)
    local dig = event.action.dig
    if event.resistance > dig.power then
        dig.damage = 0  
    end
end

-- TODO: fully implement
local function takeDigDamage(event)
    event.actor:takeDamage(event.action.dig.damage)    
end


Diggable.affectedChains =
    { 
        { "checkDig", { setBase, checkPower } },
        { "beDug", { takeDigDamage, utils.die, utils.regChangeFunc(Changes.Dug) } }
    }

Diggable.activate =
    utils.checkApplyCycle("checkDig", "beDug")
    

return Diggable
