local Attackableness = require 'logic.enums.attackableness'

local utils = {}

utils.nextToAny = function(event)

    -- if the first one is anything but nil, leave the list unchanged
    if event.targets[1].index == 1 then
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
                if 
                    t.index == indexToCheck 
                    and t.attackableness ~= Attackableness.SKIP  
                then
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
            arr[i].index < index
            and arr[i].attackableness ~= Attackableness.SKIP
        then
            return false
        end
    end
    return true
end


utils.takeFirst = function(event)
    for i, t in ipairs(event.targets) do
        if t.attackableness ~= Attackableness.SKIP then
            event.targets = { t }
            return
        end
    end
    event.targets = {}
end


utils.filter = function(filterFunc)
    return function(event)
        event.targets = filterFunc(event.targets)
    end
end


utils.unreachable = function(event)

    local newTargets = {}
    for i = 1, #event.targets do
        if
            utils.canReach(event.targets[i], event.targets)
        then
            table.insert(newTargets, event.targets[i])
        end                   
    end
    
end


utils.eliminate = function(event)

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