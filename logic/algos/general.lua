
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

    -- Iterate over action components of the action and try them in order.
    -- e.g. an AttackAction action has just one action component, which
    -- would call the executeAction() method on that instance (actor).
    -- If the action were successful, then by the end of this function
    -- call it has already been executed. Otherwise, tell the entity blocking
    -- the way to move and try again. If it resulted to a failed action yet
    -- again, try another direction. 
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
    
    local dirs = instance.sequence:getMovs(instance, action)
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