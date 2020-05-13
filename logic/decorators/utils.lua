local StatTypes = require('@decorators.dynamicstats').StatTypes


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

-- a version of check apply cycle that expects the event as one
-- of the parameters. this one has to be called manually in activation
utils.checkApplyPresetEvent = function(nameCheck, nameApply)
    return function(event)

        -- printf("Passing the %s chain", nameCheck) -- debug
        event.actor.chains[nameCheck]:pass(event, Chain.checkPropagate)

        if event.propagate then
            -- mark that the event verification succeeded
            event.success = true
            -- printf("Passing the %s chain", nameApply) -- debug
            event.actor.chains[nameApply]:pass(event, Chain.checkPropagate)
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



local Target = require "@items.weapons.target"
local Piece = require "@items.weapons.piece"
-- TODO: refactor
utils.convertToTargets = function(entities, dir, actor)
    return table.map(
        entities,
        function(entity)            
            local piece = Piece(entity.pos, dir, false)
            local attackableness = entity:getAttackableness(actor)
            local target = Target(entity, piece, 1, attackableness)
            return target
        end
    )
end


return utils