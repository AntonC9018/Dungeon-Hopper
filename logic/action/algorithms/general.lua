
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


local function Iterate(algoEvent)

    local actor = algoEvent.actor
    local action = algoEvent.action

    -- Iterate over added checks and thereupon execute actions.
    -- These checks are predefined algorithms on action types.
    -- They traverse appropriate chains on the instance.
    -- e.g. for an AttackAction action, it would traverse
    -- just the shouldAttack chain of the instance (actor) and then
    -- call executeAttack() on that instance (actor).
    -- PROBLEM: the problem is that the player is assumed to use the same action objects
    -- but they can't! they should use a separate action type that would include all
    -- actions in order and without checks
    --
    -- The problem has been remedied. 
    -- now there are separate actions for players and enemies
    -- the ones for players use a test chain inside each handler in the action's chain
    action:getChain():pass(algoEvent, Chain.checkPropagate)
    

    if not algoEvent.success then
        -- lets the real that blocks the way do its thing first
        -- if it does exist and did do something, succees would be true
        local succees = askMove(actor, action)
        
        -- after this, we should repeat this iteration
        if succees then
            return Iterate(algoEvent)    
        end
    end

    return algoEvent.success
end


-- This is a very general algo that allows one action at a time to be done
local function GeneralAlgo(enclosingEvent)
    
    local instance = enclosingEvent.actor
    local action  = enclosingEvent.action
    
    local dirs = action.getMovs(instance)
    enclosingEvent.directions = dirs

    for i = 1, #dirs do

        local algoEvent = Event(instance, action)
        algoEvent.action.direction = dirs[i]

        local succeed = Iterate(algoEvent)

        -- stop iteration after one of the actions completed successfully
        if succeed then
            enclosingEvent.success = true
            enclosingEvent.algoEvent = algoEvent
            return enclosingEvent
        end
    end

    enclosingEvent.success = false
    enclosingEvent.algoEvent = nil    
end

return GeneralAlgo