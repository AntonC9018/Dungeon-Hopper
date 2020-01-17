
local function askMove(actor, action)

    local thing = actor.world.grid:getRealAt(actor.pos + action.direction)

    if 
        thing ~= nil
        and not thing.didAction 
        and not thing.doingAction 
    then
        thing:executeAction()
        return true
    end

    return false
end


local function Iterate(event)

    -- Iterate over added checks and thereupon execute actions.
    -- These checks are predefined algorithms on action types.
    -- They traverse appropriate chains on the instance.
    -- e.g. for an AttackAction action, it would traverse
    -- just the shouldAttack chain of the instance (actor) and then
    -- call executeAttack() on that instance (actor).
    -- PROBLEM: the problem is that the player is assumed to use the same action objects
    -- but they can't! they should use a separate action type that would include all
    -- actions in order and without checks
    action.getNonPlayerChain():pass(event, Chain.checkPropagate)
    
    -- TODO: add this succeed or refactor
    -- This stuff is still a bit vague in my own mind
    if not event.propagate then
        -- lets the real that blocks the way do its thing first
        -- if it does exist and did do something, succeed would be true
        local succeed = askMove(instance, action)
        
        -- after this, we should repeat this iteration
        if succeed then
            return Iterate(instance, action)    
        end
    end

    return not event.propagate
end


-- This is a very general algo that allows one action at a time to be done
local function GeneralAlgo(outerEvent)
    
    local instance = outerEvent.actor
    local action  = outerEvent.action

    -- TODO: put this method onto instances. right now it's in the algorithms folder
    local dirs = instance:getMovs()
    event.directions = dirs

    for i = 1, #dirs do

        local event = Event(instance, action)
        event.direction = dirs[i]

        local succeed = Iterate(event)

        -- stop iteration after one of the ations completed successfully
        if succeed then
            outerEvent.success = true
            outerEvent.successEvent = event
            return outerEvent
        end
    end

    event.success = false
    outerEvent.successEvent = nil    
end

return GeneralAlgo