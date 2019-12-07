local funcs = require "funcs" 

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

    entityClass.beStatused = funcs.checkApplyCycle("checkStatus", "applyStatus")

    table.insert(entityClass.decorators, Statused)
end

return Statused