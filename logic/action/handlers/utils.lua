local utils = {}

utils.checkApplyHandler = function(checkChain, nameApplyMethod)
    return function(algoEvent)
        local actor = algoEvent.actor
        local action = algoEvent.action

        local internalEvent = Event(actor, action)

        -- printf("In algoevent calling method %s", nameCheck) -- debug
        checkChain:pass(internalEvent, Chain.checkPropagate)

        if internalEvent.propagate then    
            -- printf("In algoevent calling method %s", nameApplyMethod) -- debug
            local resultEvent = actor[nameApplyMethod](actor, action)

            algoEvent.propagate = false
            algoEvent.success = true
            algoEvent.resultEvent = resultEvent
        end

        return algoEvent
    end
end

utils.applyHandler = function(nameApplyMethod)
    return function(algoEvent)
        local actor = algoEvent.actor
        local action = algoEvent.action

        -- printf("In algoevent calling method %s", nameApplyMethod) -- debug

        local resultEvent = actor[nameApplyMethod](actor, action)  

        if resultEvent.propagate then
            -- previous action successful
            algoEvent.propagate = false
            algoEvent.success = true
            algoEvent.resultEvent = resultEvent
        end

        return algoEvent
    end
end

return utils