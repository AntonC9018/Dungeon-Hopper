local StatTypes = require('logic.decorators.dynamicstats').StatTypes


local utils = {}

utils.checkApplyCycle = function(nameCheck, nameApply)
    return function(decorator, actor, action)
        local event = Event(actor, action)

        printf("Passing the %s chain", nameCheck) -- debug
        actor.chains[nameCheck]:pass(event, Chain.checkPropagate)


        if event.propagate then
            -- mark that the event verification succeeded
            event.success = true
            printf("Passing the %s chain", nameApply) -- debug
            actor.chains[nameApply]:pass(event, Chain.checkPropagate)
        end        

        return event
    end
end

-- A modified version of check apply cycle, where instead of action
-- one is expected to get a `property`
utils.checkApplyCustomized = function(nameCheck, nameApply, property)
    return function(decorator, actor, value)
        local event = Event(actor, nil)
        event[property] = value

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
    -- A: this should probably be expandable
    -- that is, resistances should be an object (specific to e.g. attack)
    -- saved on the event. Possibly a Resistances decorator?
    -- yet another thing to consider... やれやれ...
    -- B: this should obviously be exapndable, since items could
    -- modify the armor and piercing parameters
    -- DONE!!!! (DynamicStats decorator)
    local action = event.action

    action.attack.damage = 
        clamp(
            action.attack.damage - event.resistance:get('armor'), 
            event.resistance:get('minDamage'), 
            event.resistance:get('maxDamage')
        )
        
    if action.attack.pierce <= event.resistance:get('pierce') then
        action.attack.damage = 0
    end
end


utils.die = function(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end    
end


utils.nothing = function(event)    
end


utils.regChangeFunc = function(code)
    return function(event)
        event.actor.world:registerChange(event.actor, code)
    end
end


utils.setAttackRes = function(event)
    event.resistance = event.actor:getStat(StatTypes.AttackRes)
end


return utils