
local identity = function(event)
    return event
end

-- TODO: implemet these methods
local checkStatus = identity
local applyStatus = identity

local Statused = function(entityClass)
    local template = entityClass.chainTemplate

    template:addChain("checkStatus")
    template:addChain("applyStatus")

    -- TODO: implement
    template:addHandler("checkStatus", checkStatus)
    template:addHandler("applyStatus", applyStatus)

    function entityClass:bePushed(action)
        local event = Event(self, action)

        local result = 
            self.chains.checkStatus:pass(event, Chain.checkPropagate)

        if not result.propagate then    
            return false
        end

        self.chains.applyStatus:pass(event, Chain.checkPropagate)

        return result.propagate
    end

    table.insert(entityClass.decorators, Statused)
end

return Statused