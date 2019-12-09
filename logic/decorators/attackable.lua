local funcs = require "funcs" 

-- TODO: fully implement
local function takeHit(event)
    event.actor:takeDamage(event.action.attack.damage)
    return event
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end
    return event
end

local function armor(armor, max)
    return function(event)
        event.attack.damage = 
            clamp(event.attack.damage - armor, 1, max or math.huge)
        return event
    end
end


local Attackable = function(entityClass)
    local template = entityClass.chainTemplate

    if template:isNil("defense") then
        template:addChain("defense")
        template:addHandler("defense", armor(entityClass.base.armor))
    end
    
    template:addChain("beHit")
    template:addHandler("beHit", takeHit)
    template:addHandler("beHit", die)

    entityClass.beAttacked = funcs.checkApplyCycle("defense", "beHit")

    table.insert(entityClass.decorators, Attackable)
end

return Attackable