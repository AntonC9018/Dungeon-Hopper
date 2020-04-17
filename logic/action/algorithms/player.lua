
local function PlayerAlgo(enclosingEvent)

    print("Player algo called")

    local actor = enclosingEvent.actor
    -- action already has the action.direction here
    local action = enclosingEvent.action


    local algoEvent = Event(actor, action)

    print(class.name(action))
    print(action:getPlayerChain())

    action:getPlayerChain():pass(algoEvent, Chain.checkPropagate)

    -- resultEvent is already set here, see handlers/player.lua

    return enclosingEvent
end

return PlayerAlgo