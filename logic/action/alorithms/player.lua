
local function PlayerAlgo(outerEvent)

    local actor = outerEvent.actor
    -- action already has the action.direction here
    local action = outerEvent.action

    local event = Event(actor, action)

    action:getPlayerChain():pass(event, Chain.checkPropagate)

    if event.propagate then
        -- traverse failedAction chain
        -- return instance.chains.failedAction:pass(postActionEvent)
        outerEvent.success = false
        outerEvent.successEvent = nil
        return outerEvent
    end

    outerEvent.success = true
    outerEvent.successEvent = event
    return outerEvent
end

return PlayerAlgo