
local function PlayerAlgo(instance, action)
    local event = Event(instance, action)
    action:getPlayerChain():pass(event, Chain.checkPropagate)
    
    local postActionEvent = Event(instance, action)
    postActionEvent.actionEvent = event

    if event.propagate then
        -- traverse failedAction chain
        return instance.chains.failedAction:pass(postActionEvent)
    end

    return instance.chains.succeedAction:pass(postActionEvent)
end

return PlayerAlgo