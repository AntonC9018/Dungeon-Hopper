
local _do = {}

local function doX(funcName)
    return function(targets, action)
        local events = {}
        local initialDirection = action.direction
        for i = 1, #targets do
            local entity = targets[i].entity
            action.direction = targets[i].piece.dir
            events[i] = entity[funcName](entity, action)
        end
        action:setDirection(initialDirection)
        return events
    end
end

-- define all do<something> functions
_do.attack = doX('beAttacked')
_do.dig    = doX('beDug')
_do.push   = doX('bePushed')
_do.status = doX('beStatused')

return _do