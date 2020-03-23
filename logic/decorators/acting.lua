local Decorator = require 'decorator'
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
        
    instance.doingAction = true

    local enclosingEvent = Event(instance, instance.nextAction)
    enclosingEvent.success = false
    instance.enclosingEvent = enclosingEvent

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