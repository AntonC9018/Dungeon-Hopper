local utils = require '@retouchers.utils'

local reorient = {}


local function reorientMoveHandler(event)
    event.actor:reorient(event.move.direction)
end

reorient.onMove = function(entityClass)
    utils.retouch(entityClass, 'move', reorientMoveHandler)
end

reorient.onDisplace = function(entityClass)
    utils.retouch(entityClass, 'displace', reorientMoveHandler)
end



local function reorientActionCheckHandler(event)
    if event.action.direction ~= nil then
        event.actor:reorient(event.action.direction)
    end
end

reorient.onActionSuccess = function(entityClass)
    utils.retouch(entityClass, 'succeedAction', reorientActionCheckHandler)
end



local function reorientActionHandler(event)
    event.actor:reorient(event.action.direction)
end

reorient.onAttack = function(entityClass)
    utils.retouch(entityClass, 'attack', reorientHandler)
end

reorient.onDig = function(entityClass)
    utils.retouch(entityClass, 'dig', reorientHandler)
end


return reorient