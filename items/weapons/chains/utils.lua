local utils = {}

utils.nextToAny = function(event)

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
        event.targets = {}
    end
    
end


-- TODO: Add a skip option
utils.filterUnattackable = function(targets)
    local newTargets = {}
    for i, target in ipairs(targets) do
        if target.attackableness ~= Attackableness.NO then
            table.insert(newTargets, target)
        end
    end
    return newTargets
end


utils.canReach = function(target, targets)

    -- no reach option
    if not target.reach then
        return true
    end

    -- if not specified a list of indeces
    if target.reach == true then
        return utils.isLowestIndex(target.index, targets)
    end

    -- if did specify a list of indices
    for _, t in ipairs(targets) do
        if t ~= nil then
            for _, indexToCheck in ipairs(target.reach) do
                -- that index has been blocked
                if t.index == indexToCheck then
                    return false
                end
            end
        end
    end

    return true
end


utils.isLowestIndex = function(index, arr)
    for i = 1, #arr do
        if 
            arr[i] ~= nil 
            and arr[i].index < index 
        then
            return false
        end
    end
    return true
end


utils.takeFirst = function(event)
    event.targets = { event.targets[1] }    
end


utils.checkStop = function(event)
    return Chain.stopPropagate(event) or stopIfEmpty(event)
end


utils.stopIfEmpty = function(event)
    if 
        #event.targets == 0
    then
        event.targets = {}
        return true  
    end
end


utils.unreachable = function(event)

    local newTargets = {}
    for i = 1, #event.targets do
        local reach = event.targets[i].piece.reach 
        local index = event.targets[i].index
        if
            utils.canReach(index, event.targets)
        then
            table.insert(newTargets, event.targets[i])
        end                   
    end
    
end


utils.eliminate = function(event)

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


return utils