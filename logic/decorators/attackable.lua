
-- TODO: fully implement
local function takeHit(event)
    event.entity:takeDamage(event.action.attack.damage)
    return event
end

local function die(event)
    if event.entity.hp:get() <= 0 then
        event.entity.dead = true
        event.entity:die()
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

    function entityClass:beAttacked(action)
        local event = Event(self, action)
        local result = 
            self.chains.defence:pass(event, Chain.checkPropagate)

        if not result.propagate then    
            return
        end

        self.chains.beHit:pass(event, Chain.checkPropagate)
    end

    table.insert(entityClass.decorators, Attackable)
end

return Attackable