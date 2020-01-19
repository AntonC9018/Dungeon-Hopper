local utils = require "utils" 

local identity = function(event)
    
end

-- TODO: implemet these methods
local checkStatus = identity
local applyStatus = identity

-- TODO: traverse a chain of statuses
local checkStatuses = identity

local Statused = function(entityClass)
    local template = entityClass.chainTemplate

    if not template:isSetChain("checkAction") then
        template:addChain("checkAction")
    end

    template:addChain("checkStatus")
    template:addChain("applyStatus")

    -- TODO: implement
    template:addHandler("checkStatus", checkStatus)
    template:addHandler("applyStatus", applyStatus)

    entityClass.beStatused = utils.checkApplyCycle("checkStatus", "applyStatus")

    template:addHandler("checkAction", checkStatuses)

    table.insert(entityClass.decorators, Statused)
end

return Statused