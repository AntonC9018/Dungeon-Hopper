local utils = require "utils" 

-- TODO: implement these methods
local checkStatus = utils.nothing
local applyStatus = utils.nothing
local checkStatuses = utils.nothing

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