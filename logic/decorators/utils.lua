local utils = {}

utils.checkApplyCycle = function(nameCheck, nameApply)
    return function(decorator, actor, action)
        local event = Event(actor, action)

        -- printf("Passing the %s chain", nameCheck) -- debug
        actor.chains[nameCheck]:pass(event, Chain.checkPropagate)


        if event.propagate then
            -- mark that the event verification succeeded
            event.success = true
            -- printf("Passing the %s chain", nameApply) -- debug
            actor.chains[nameApply]:pass(event, Chain.checkPropagate)
        end        

        return event
    end
end



utils.armor = function(event)
    local actor = event.actor
    local resitances = actor.baseModifiers.resistance
    local action = event.action

    action.attack.damage = 
        clamp(
            action.attack.damage - resitances.armor, 
            1, 
            resitances.maxDamage or math.huge
        )
        
    if action.attack.pierce > resitances.pierce then
        action.attack.damage = 0  
    end
end

utils.nothing = function(event)    
end

utils.regChangeFunc = function(code)
    return function(event)
        event.actor.world:registerChange(event.actor, code)
    end
end

return utils