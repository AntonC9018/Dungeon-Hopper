local funcs = require "funcs" 

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

    entityClass.executePush = funcs.checkApplyCycle("checkPush", "applyPush")

    table.insert(entityClass.decorators, Pushable)

end

return Pushable