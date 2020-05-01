local utils = require 'logic.retouchers.utils'

local skip = {}

-- ignoring empty cells while attacking and digging
local function skipEmpty(event)
    if #event.targets == 0 then
        event.propagate = false    
    end
end

skip.emptyAttack = function(entityClass)
    utils.retouch(entityClass, 'getAttack', skipEmpty)
end

skip.emptyDig = function(entityClass)
    utils.retouch(entityClass, 'getDig', skipEmpty)
end

-- ignoring move if the cell is blocked
local function skipBlocked(event)
    local coord = 
        event.actor.pos + event.action.direction
    local top =
        event.actor.world.grid:hasBlockAt(coord)
    
    if top ~= nil then
        event.propagate = false  
    end
end

skip.blockedMove = function(entityClass)
    utils.retouch(entityClass, 'getMove', skipBlocked)
end


-- proceed only if targets include player
local function skipNoPlayer(event)
    -- someF is the function some that accepts a check function
    event.propagate = table.somef(
        event.targets, 
        function(target)
            return target.entity:isPlayer()
        end
    )
end

skip.noPlayer = function(entityClass)
    utils.retouch(entityClass, 'getAttack', skipNoPlayer)
end

return skip