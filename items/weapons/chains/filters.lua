local Attackableness = require 'logic.enums.attackableness'

local filters = {}

filters.Nil = function(targets)
    local newTargets = {}
    for i, target in ipairs(targets) do
        if target.entity ~= nil then
            table.insert(newTargets, target)
        end
    end
    return newTargets
end


filters.Unattackable = function(targets)
    local newTargets = {}
    for i, target in ipairs(targets) do
        if 
            target.attackableness ~= Attackableness.NO
        then
            table.insert(newTargets, target)
        end
    end
    return newTargets
end


filters.LeaveAttackable = function(targets)
    local newTargets = {}
    for i, target in ipairs(targets) do
        if 
            target.attackableness == Attackableness.YES 
            or target.attackableness == Attackableness.IF_CLOSE 
        then
            table.insert(newTargets, target)
        end
    end
    return newTargets
end


return filters