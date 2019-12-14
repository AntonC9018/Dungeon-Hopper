local funcs = require "funcs" 
-- TODO: fully implement
local function beExploded(event)
    event.actor:takeDamage(event.action.special.damage)
    
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end
    
end


local Explodable = function(entityClass)
    local template = entityClass.chainTemplate

    if template:isNil("defense") then
        template:addChain("defense")
        template:addHandler("defense", armor(entityClass.base.armor))
    end
    
    template:addChain("beingExploded")
    template:addHandler("beingExploded", beExploded)
    template:addHandler("beingExploded", die)

    entityClass.beAttacked = funcs.checkApplyCycle("defence", "beingExploded")

    table.insert(entityClass.decorators, Explodable)
end

return Explodable