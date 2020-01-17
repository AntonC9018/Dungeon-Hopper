local utils = require "utils" 

local function getBaseMove(action)
    local move = Move(action.direction, action.actor.base.move)
    event.move = move
    
end


local function displace(event)    
    local move = event.move
    event.actor.world:displace(event.actor, event.move)    
    
end


local Moving = function(entityClass)

    local template = entityClass.chainTemplate
    
    template:addChain("getMove")
    template:addChain("move")

    template:addHandler("getMove", getBaseMove)
    template:addHandler("move", displace)

    entityClass.executeMove = utils.checkApplyCycle("getMove", "move")

    table.insert(entityClass.decorators, Moving)
end

return Moving