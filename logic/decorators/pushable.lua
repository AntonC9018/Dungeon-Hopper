local utils = require "utils" 

-- TODO: implement these methods
local checkPush = function(event)
    if event.action.push.power < event.actor.baseModifiers.resistance.push then
        event.propagate = false
    end
end

local executePush = function(event)
    local move = event.action.push:toMove(event.action.direction)
    -- actor is the thing being pushed
    event.actor.world:displace(event.actor, move)    
end

local Pushable = function(entityClass)
    local template = entityClass.chainTemplate

    template:addChain("checkPush")
    template:addChain("executePush")

    template:addHandler("checkPush", checkPush)
    template:addHandler("executePush", executePush)

    entityClass.executePush = utils.checkApplyCycle("checkPush", "executePush")

    table.insert(entityClass.decorators, Pushable)

end

return Pushable