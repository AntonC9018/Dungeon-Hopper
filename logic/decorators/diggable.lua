local utils = require "@decorators.utils" 
local Changes = require 'render.changes'
local Decorator = require '@decorators.decorator'

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
        { "checkDig", 
            { 
                { setBase, Ranks.HIGH }, 
                checkPower 
            } 
        },

        { "beDug", 
            { 
                takeDigDamage,
                utils.regChangeFunc(Changes.Dug), 
                { utils.die, Ranks.LOW }
            } 
        }
    }

Diggable.activate =
    utils.checkApplyCycle("checkDig", "beDug")
    

return Diggable
