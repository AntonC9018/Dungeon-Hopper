local Chain = require "lib.chains.chain"
local Action = require "logic.action.action"

local handlers = {}


handlers.turnToPlayer = function(event)

    local world = event.actor.world
    local coord = event.actor.pos
    local player = world:getClosestPlayer()

    local difference = player.pos - coord
    local x, y = difference:abs():comps()

    if x > y then
        local newX = sign(difference.x)
        event.actor.orientation = Vec(newX, 0)
    else
        local newY = sign(difference.y)
        event.actor.orientation = Vec(0, newY)
    end

end


handlers.checkOrthogonal = function(event)

    local world = event.actor.world
    local coord = event.actor.pos
    local player = world:getClosestPlayer()

    event.propagate = 
        coord.x == player.x or coord.y == player.y

end


handlers.checkNotMove = function(event)
    event.propagate = not event.actor:didMove()
end


handlers.checkTargetsHavePlayer = function(event)

    local targets = event.targets

    if targets == nil then
        event.propagate = false
        return
    end

    event.propagate = 
        table.someF(
            targets, 
            function(target)
                return target.entity:isPlayer()
            end
        )
end

handlers.checkFreeMove = function(event)

    local coord = 
        event.actor.pos + event.action.direction
    local top =
        event.actor.world:getOneFromTopAt(coord)
    
    if top ~= nil then
        event.propagate = false  
    end
end


return handlers