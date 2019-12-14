

local Acting = function(entityClass)

    local template = entityClass.chainTemplate

    if template:isNil("checkAction") then
        template:addChain("checkAction")
    end
    template:addChain("action")

    template:addChain("failedAction")
    tamplate:addChain("succeedAction")

    local function executeAction(instance)
        
        instance.doingAction = true

        local event = Event(instance, instance.nextAction)
        event.success = false
        instance.currentActionEvent = event

        -- check if action should event be done
        -- checks to this are added mainly by statused
        -- to control, e.g., being frozen and stuff
        -- if a character is frozen, all his actions are
        -- considered failed, and the checkSuccess on the Event is set to false
        instance.chain.checkAction:pass(event)

        event.checkSuccess = event.propagate

        -- if the checks have succeeded, try to do the action
        if event.checkSuccess then
            event.propagate = true
            instance.chains.action:pass(event)
        end

        event.propagate = true

        if event.success then
            instance.chains.successAction:pass(event)
        else
            instance.chains.failedAction:pass(event)            
        end

        instance.doingAction = false
        instance.didAction = true        
    end

    instance.executeAction = executeAction

    table.insert(entityClass.decorators, Acting)

end

return Acting