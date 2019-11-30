
-- TODO: fully implement
local function takeHit(entity, action)
    entity:takeDamage(action.attack.damage)
end

local function die(entity, action)
    if entity.hp:get() <= 0 then
        entity.dead = true
        entity:die()
    end
end


local Attackable = function(entityClass)
    local template = entityClass.chainTemplate
    if template:isNil("defense") then
        template:addChain("defense")
    end
    template:addChain("beingHit")
    template:addMethod("beingHit", takeHit)
    template:addMethod("beingHit", die)
end