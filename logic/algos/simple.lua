
local function SimpleAlgo(enclosingEvent)

    local actor = enclosingEvent.actor
    -- action already has the action.direction here
    local action = enclosingEvent.action


    local algoEvent = Event(actor, action)

    -- print(class.name(action)) -- debug
    
    action:getChain():pass(algoEvent, Chain.checkPropagate)

    enclosingEvent.success = algoEvent.success
    
    -- resultEvent is already set here, see handlers/player.lua

    return enclosingEvent
end

return SimpleAlgo