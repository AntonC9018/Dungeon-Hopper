

local Acting = function(entityClass)

    local template = entityClass.chainTemplate

    if not template:isSetChain("checkAction") then
        template:addChain("checkAction")
    end
    template:addChain("action")

    template:addChain("failedAction")
    tamplate:addChain("succeedAction")

    local function executeAction(instance)
        
        instance.doingAction = true

        local enclosingEvent = Event(instance, instance.nextAction)
        enclosingEvent.success = false
        instance.enclosingEvent = enclosingEvent

        -- check if action should even be done
        -- checks to this are added mainly by statused
        -- to control, e.g., being frozen and stuff
        -- if a character is frozen, all his actions are
        -- considered failed, and the checkSuccess on the Event is set to false
        instance.chain.checkAction:pass(enclosingEvent)

        enclosingEvent.checkSuccess = enclosingEvent.propagate

        -- if the checks have succeeded, try to do the action
        -- in most cases, the action chain is going to include just the
        -- GeneralAlgo function
        if enclosingEvent.checkSuccess then
            enclosingEvent.propagate = true
            instance.chains.action:pass(enclosingEvent)
        end

        enclosingEvent.propagate = true

        if enclosingEvent.success then
            instance.chains.succeedAction:pass(enclosingEvent)
        else
            instance.chains.failedAction:pass(enclosingEvent)            
        end

        instance.doingAction = false
        instance.didAction = true        
    end

    instance.executeAction = executeAction

    table.insert(entityClass.decorators, Acting)

end

return Acting