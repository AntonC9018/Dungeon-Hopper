
local function PlayerAlgo(instance, action)
    local event = Event(actor, action)
    action.chains.player:pass(event, Chain.checkPropagate)

    if event.propagate then
        -- traverse failedAction chain
        local event = Event(instance, action)
        return instance.chains.failedAction:pass(event)
    end

    return event
end

return PlayerAlgo