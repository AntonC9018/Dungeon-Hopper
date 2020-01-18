
local function PlayerAlgo(enclosingEvent)

    local actor = enclosingEvent.actor
    -- action already has the action.direction here
    local action = enclosingEvent.action

    local algoEvent = Event(actor, action)

    action:getPlayerChain():pass(algoEvent, Chain.checkPropagate)

    -- resultEvent is already set here, see handlers/player.lua

    return enclosingEvent
end

return PlayerAlgo