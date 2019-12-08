
local askMove(actor, action)

    local thing = actor.world.grid:getRealAt(actor.pos + action.direction)

    if 
        thing ~= nil
        and not thing.doneAction 
        and not thing.doingAction 
    then
        thing:executeAction()
        return true
    end

    return false
end


local function Iterate(actor, action)

    local event = Event(actor, action)

    -- Iterate over added checks and thereupon execute actions.
    -- These checks are predefined algorithms on action types.
    -- They traverse appropriate chains on the actor object.
    -- e.g. for an AttackAction action, the chain would traverse
    -- just the shouldAttack chain of the actor and then
    -- call executeAttack().
    -- PROBLEM: the problem is that the player is assumed to use the same action objects
    -- but they can't! they should use a separate action type that would include all
    -- actions in order and without checks
    action.chain:pass(event, Chain.checkPropagate)
    
    -- TODO: add this succeed or refactor
    -- This stuff is still a bit vague in my own mind
    if not event.propagate then
        -- lets the real that blocks the way do its thing first
        -- if it does exist and did do something, succeed would be true
        local succeed = askMove(actor, action)
        
        -- after this, we should repeat this iteration
        if succeed then
            return Iterate(actor, action)    
        end
    end

    return not event.propagate
end


-- This is a very general algo that allows one action at a time to be done
local function GeneralAlgo(instance, action)

    -- TODO: put this method onto instances. right now it's in the algorithms folder
    local movs = instance:getMovs()

    for i = 1, #movs do

        action.direction = movs[i]

        local succeed = Iterate(actor, action)

        -- stop iteration after one of the ations completed successfully
        if succeed then
            return true
        end
    end

    if not succeed then
        -- traverse failedAction chain
        local event = Event(instance, action)
        event.movs = movs

        return instance.chains.failedAction:pass(event)
    end
end

return GeneralAlgo