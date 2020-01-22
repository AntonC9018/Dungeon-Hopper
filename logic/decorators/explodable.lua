local utils = require "utils" 

-- TODO: fully implement
local function beExploded(event)
    event.actor:takeDamage(event.action.special.damage)11    
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end    
end


local Explodable = function(entityClass)
    local template = entityClass.chainTemplate

    if not template:isSetChain("defense") then
        template:addChain("defense")
        template:addHandler("defense", armor(entityClass.baseModifiers.armor))
    end
    
    template:addChain("beingExploded")
    template:addHandler("beingExploded", beExploded)
    template:addHandler("beingExploded", die)

    entityClass.beAttacked = utils.checkApplyCycle("defence", "beingExploded")

    table.insert(entityClass.decorators, Explodable)
end

return Explodable