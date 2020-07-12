
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

    action:getChain():pass(algoEvent, Chain.checkPropagate)    

    if not algoEvent.success then
        -- lets the real that blocks the way do its thing first
        -- if it does exist and did do something, succees would be true
        local succees = askMove(actor, action)
        
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