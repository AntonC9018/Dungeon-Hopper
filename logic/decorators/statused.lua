local funcs = require "funcs" 

local identity = function(event)
    
end

-- TODO: implemet these methods
local checkStatus = identity
local applyStatus = identity

-- TODO: traverse a chain of statuses
local checkStatuses = identity

local Statused = function(entityClass)
    local template = entityClass.chainTemplate

    if template:isNil("checkAction") then
        template:addChain("checkAction")
    end

    template:addChain("checkStatus")
    template:addChain("applyStatus")

    -- TODO: implement
    template:addHandler("checkStatus", checkStatus)
    template:addHandler("applyStatus", applyStatus)

    entityClass.beStatused = funcs.checkApplyCycle("checkStatus", "applyStatus")

    template:addHandler("checkAction", checkStatuses)

    table.insert(entityClass.decorators, Statused)
end

return Statused