local Decorator = require '@decorators.decorator'
local Acting = class('Acting', Decorator)

Acting.affectedChains =
    { 
        { "checkAction", {} },
        { "action", {} },
        { "failAction", {} },
        { "succeedAction", {} }    
    }


-- execute action function
function Acting:activate(instance)        

    local enclosingEvent = Event(instance, instance.nextAction)
    enclosingEvent.success = false
    instance.enclosingEvent = enclosingEvent

    -- nil event check
    if instance.nextAction:getChain() == nil then
        instance.didAction = true
        enclosingEvent.success = true
        instance.chains.succeedAction:pass(enclosingEvent)
        return
    end

    instance.doingAction = true

    -- check if action should even be done
    -- checks to this are added mainly by statused
    -- to control, e.g., being frozen and stuff
    -- if a character is frozen, all his actions are
    -- considered fail, and the checkSuccess on the Event is set to false
    instance.chains.checkAction:pass(enclosingEvent)

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
        instance.chains.failAction:pass(enclosingEvent)            
    end

    instance.doingAction = false
    instance.didAction = true        
end


return Acting