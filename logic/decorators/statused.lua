
local identity = function(event)
    return event
end

-- TODO: implemet these methods
local push = identity
local applyStatus = identity

local Statused = function(entityClass)
    local template = entityClass.chainTemplate

    template:addChain("checkStatus")
    template:addChain("applyStatus")

    function entityClass:bePushed(action)
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