local funcs = require "funcs" 

local identity = function(event)
    
end

-- TODO: implemet these methods
local checkPush = identity
local executePush = function(event)
    local move = event.push:toMove()
    -- target is myself here
    event.target.world:displace(event.target, move)
    
end

local Pushable = function(entityClass)
    local template = entityClass.chainTemplate

    template:addChain("checkPush")
    template:addChain("executePush")

    template:addHandler("checkPush", checkPush)
    template:addHandler("executePush", executePush)

    entityClass.executePush = funcs.checkApplyCycle("checkPush", "executePush")

    table.insert(entityClass.decorators, Pushable)

end

return Pushable