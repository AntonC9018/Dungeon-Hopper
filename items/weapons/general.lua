local Chain = require "lib.chains.chain"


-- Check if hitting AttackableOnlyWhenNextToAttacker, 
-- without being next to any (return nothing in this case) ->
-- HitAll? (leave all) -> 
-- Eliminate AttackableOnlyWhenNextToAttacker that aren't close ->
-- Check unreachableness (eliminate unreachable ones) ->
-- Take the first available

local function next(event)

    -- if the first one is anything but nil, leave the list unchanged
    if event.targets[1] ~= nil
        return event
    end

    -- otherwise, check if not everything is Attackable...blah-blah 
    local all = true
    for i = 1, #event.targets do
        if not event.targets[i]:isAttackableOnlyWhenNextToAttacker() then
            all = false
            break
        end
    end
    
    -- if all are, return nothing as the targets
    if all then
        event.propagate = false
        event.targets = nil
    end

    return event
end


local function hitAll(event)
    if event.actor.hitAll then
        event.propagate = false
    end
    return event
end


local function isLowestIndex(index, arr)
    for i = 1, #arr do
        if arr[i].index < index then
            return false  
        end
    end
    return true
end


local function unreachable(event)
    local newTargets = {}
    for i = 1, #event.targets do
        local reach = event.targets[i].piece.reach 
        local index = event.targets[i].index
        if
            -- reach == false means it reaches that entity no matter what
            reach == false
            -- reach == true means that all the ones before
            -- (at lower indices) should be nil in order to hit this
            -- that is, this index should be the lowest
            or isLowestIndex(index, event.targets)
        then
            table.insert(newTargets, event.targets[i])
        end                   
    end
    return event
end


local function eliminate(event)
    local newTargets = {}
    for i = 1, event.targets[i] do
        if 
            event.targets[i]:isAttacckable()
            and (not event.targets[i]:isAttackableOnlyWhenNextToAttacker() 
            or event.targets[i].index == 1)
        then
            table.insert(newTargets, event.targets[i])
        end
    end
    event.targets = newTargets
    return event
end


local function takeFirst(event)
    event.targets = { event.targets[1] }
    return event
end


local function stopIfEmpty(event)
    if 
        event.targets == nil
        or #event.targets == 1
    then
        event.targets = nil
        return true  
    end
end


local function checkStop(event)
    return Chain.stopPropagate(event) or stopIfNil(event)
end

-- define a general chain
local chain = Chain()

chain:addHandler(next)
chain:addHandler(hitAll)
chain:addHandler(isLowestIndex)
chain:addHandler(unreachable)
chain:addHandler(eliminate)
chain:addHandler(takeFirst)


return {
    chain = chain,
    check = checkStop
}
