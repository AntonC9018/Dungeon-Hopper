local utils = {}


utils.applyHandler = function(nameApplyMethod)
    return function(algoEvent)
        local actor = algoEvent.actor
        local action = algoEvent.action

        -- printf("In algoevent calling method %s", nameApplyMethod) -- debug

        local resultEvent = actor[nameApplyMethod](actor, action)  

        if resultEvent.success then
            -- previous action successful
            algoEvent.propagate = false
            algoEvent.success = true
            algoEvent.resultEvent = resultEvent
        end

        return algoEvent
    end
end


utils.activateDecorator = function(name)
    return function(algoEvent)
        local actor = algoEvent.actor
        local action = algoEvent.action

        local resultEvent = actor.decorators[name]:activate(actor, action)  

        if resultEvent.success then
            -- previous action successful
            algoEvent.propagate = false
            algoEvent.success = true
            algoEvent.resultEvent = resultEvent
        end

        return algoEvent
    end
end


utils.applyFunctionHandler = function(func)
    return function(algoEvent)
        local actor = algoEvent.actor
        local action = algoEvent.action

        -- printf("In algoevent calling method %s", nameApplyMethod) -- debug

        local resultEvent = func(actor, action)  

        if resultEvent.success then
            -- previous action successful
            algoEvent.propagate = false
            algoEvent.success = true
            algoEvent.resultEvent = resultEvent
        end

        return algoEvent
    end
end

return utils