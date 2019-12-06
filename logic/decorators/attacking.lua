
local function getBase(event)
    event.attack = Attack(event.entity.baseStats.attack)
    event.status = Amounts(event.entity.baseStats.status)
    event.push = Push(event.entity.baseStats.push)
    return event
end

local function applyAttack(event)
    local hit = event.entity.world:doAttack(event.entity, event.attack)
    if hit ~= nil then
        event.target = hit
    else
        event.propagate = false
    end
    return event
end

local function applyPush(event)
    event.entity.world:doPush(event.entity, event.push)
    return event
end

local function applyStatus(event)
    event.entity.world:doStatus(event.entity, event.status)
    return event
end


local Attacking = function(entityClass)
    local template = entityClass.chainTemplate

    template:addChain("getAttack")
    template:addHandler("getAttack", setBase)

    template:addChain("attack")
    template:addHandler("attack", applyAttack)
    template:addHandler("attack", applyPush)
    template:addHandler("attack", applyStatus)

    function entityClass:executeAttack(action)
        local event = Event(self, action)

        local result = 
            self.chains.getAttack:pass(event, Chain.checkPropagate)

        if not result.propagate then    
            return false
        end

        self.chains.attack:pass(event, Chain.checkPropagate)

        return result.propagate
    end
end

return Attacking