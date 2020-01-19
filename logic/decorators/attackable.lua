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

local function armor(armor, max)
    return function(event)
        event.attack.damage = 
            clamp(event.attack.damage - armor, 1, max or math.huge)        
    end
end


local Attackable = function(entityClass)
    local template = entityClass.chainTemplate

    if template:isSetChain("defense") then
        template:addChain("defense")
        template:addHandler("defense", armor(entityClass.base.armor))
    end
    
    template:addChain("beHit")
    template:addHandler("beHit", takeHit)
    template:addHandler("beHit", die)

    entityClass.beAttacked = utils.checkApplyCycle("defense", "beHit")

    table.insert(entityClass.decorators, Attackable)
end

return Attackable