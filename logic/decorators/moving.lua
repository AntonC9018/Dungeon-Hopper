local funcs = require "funcs" 

local function getBaseMove(action)
    local move = Move(action.direction, action.entity.base.move)
    event.move = move
    return event
end


local function displace(event)    
    local move = event.move
    event.entity.world:displace(event.entity, event.move)    
    return event
end


local Moving = function(entityClass)

    local template = entityClass.chainTemplate
    
    template:addChain("getMove")
    template:addChain("move")

    template:addHandler("getMove", getBaseMove)
    template:addHandler("move", displace)

    entityClass.executeMove = funcs.checkApplyCycle("getMove", "move")

    table.insert(entityClass.decorators, Moving)
end

return Moving