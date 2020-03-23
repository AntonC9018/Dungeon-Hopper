local utils = require "utils" 

local Decorator = require 'decorator'
local Attackable = class('Attackable', Decorator)


-- TODO: fully implement
local function takeHit(event)
    event.actor:takeDamage(event.action.attack.damage)    
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end
    
end

local function armor(protectionModifier)
    return function(event)
        event.attack.damage = 
            clamp(
                event.attack.damage - protectionModifier.armor, 
                1, 
                protectionModifier.maxDamage or math.huge
            )
        if event.attack.pierce > protectionModifier.pierce then
            event.attack.damage = 0  
        end
    end
end


Attackable.affectedChains =
    { 
        { "defense", { armor(entityClass.baseModifiers.protection) } },
        { "beHit", { takeHit, die } }
    }

Attackable.activate =
    utils.checkApplyCycle("defense", "beHit")

    
return Attackable