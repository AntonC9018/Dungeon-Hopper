local utils = require "utils" 

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


local Attackable = function(entityClass)
    local template = entityClass.chainTemplate

    if not template:isSetChain("defense") then
        template:addChain("defense")
        template:addHandler("defense", armor(entityClass.baseModifiers.protection))
    end
    
    template:addChain("beHit")
    template:addHandler("beHit", takeHit)
    template:addHandler("beHit", die)

    entityClass.beAttacked = utils.checkApplyCycle("defense", "beHit")

    table.insert(entityClass.decorators, Attackable)
end

return Attackable