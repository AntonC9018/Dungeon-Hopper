local identity = function(event)
    return event
end

-- TODO: implemet these methods
local checkPush = identity
local applyPush = identity

local Pushable = function(entityClass)
    local template = entityClass.chainTemplate

    template:addChain("checkPush")
    template:addChain("applyPush")

    template:addHandler("checkPush", checkPush)
    template:addHandler("applyPush", applyPush)

    function entityClass:executePush(action)
        local event = Event(self, action)

        local result = 
            self.chains.checkPush:pass(event, Chain.checkPropagate)

        if not result.propagate then    
            return false
        end

        self.chains.applyPush:pass(event, Chain.checkPropagate)

        return result.propagate
    end

end