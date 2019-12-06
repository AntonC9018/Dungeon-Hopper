-- TODO: fully implement
local function beExploded(event)
    event.entity:takeDamage(event.action.special.damage)
    return event
end

local function die(event)
    if event.entity.hp:get() <= 0 then
        event.entity.dead = true
        event.entity:die()
    end
    return event
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

     function entityClass:beAttacked(action)
        local event = Event(self, action)
        local result = 
            self.chains.defence:pass(event, Chain.checkPropagate)

        if not result.propagate then    
            return
        end

        self.chains.beingExploded:pass(event, Chain.checkPropagate)
    end

    table.insert(entityClass.decorators, Explodable)
end

return Explodable