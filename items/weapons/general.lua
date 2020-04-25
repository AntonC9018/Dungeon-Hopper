local Attackableness = require "logic.enums.attackableness"
-- Check if hitting AttackableOnlyWhenNextToAttacker, 
-- without being next to any (return nothing in this case) ->
-- -> HitAll? (leave all) -> 
-- -> Check unreachableness (eliminate unreachable ones) ->
-- -> Eliminate targets with Attackableness.IS_CLOSE that aren't close and those with Attackableness.NO ->
-- -> Take the first available

local function nextToAny(event)

    -- if the first one is anything but nil, leave the list unchanged
    -- NOTE: at this point the list of targets still corresponds
    -- to the pattern attack order
    if event.targets[1].entity ~= nil then
        return
    end

    -- otherwise, check if not everything is attackable only when we're close
    local all = true
    for i = 1, #event.targets do
        if event.targets[i].attackableness ~= Attackableness.IF_NEXT_TO then
            all = false
            break
        end
    end
    
    -- if all are, return nothing as the targets
    if all then
        event.propagate = false
        event.targets = nil
    end
    
end


local function filterUnattackable(targets)
    local newTargets = {}
    for i, target in ipairs(targets) do
        if target.attackableness ~= Attackableness.NO then
            table.insert(newTargets, target)
        end
    end
    return newTargets
end


local function hitAll(event)
    if event.hitAll then
        event.propagate = false
        -- we also need to filter out NO-es
        event.targets = 
            filterUnattackable(event.targets)
    end
    
end


local function isLowestIndex(index, arr)
    for i = 1, #arr do
        if arr[i] ~= nil and arr[i].index < index then
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
    
end


local function eliminate(event)
    event.targets = 
        filterUnattackable(event.targets)

    local newTargets = {}

    for i, target in ipairs(event.targets) do
        if 
            target.attackableness ~= Attackableness.IF_NEXT_TO
            or target.index == 1
        then
            table.insert(newTargets, target)
        end
    end
    event.targets = newTargets
    
end


local function takeFirst(event)
    event.targets = { event.targets[1] }    
end


local function stopIfEmpty(event)
    if 
        event.targets == nil
        or #event.targets == 0
    then
        event.targets = nil
        return true  
    end
end


local function checkStop(event)
    return Chain.stopPropagate(event) or stopIfEmpty(event)
end

-- define a general chain
local chain = Chain(
    {
        nextToAny,
        hitAll,
        unreachable,
        eliminate,
        takeFirst
    }
)

return {
    chain = chain,
    check = checkStop
}
