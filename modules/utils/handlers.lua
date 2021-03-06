local Action = require "@action.action"
local Changes = require 'render.changes'

local handlers = {}


handlers.turnToPlayer = function(event)

    local actor = event.actor
    local world = actor.world
    local coord = actor.pos
    local player = world.grid:getClosestPlayer(actor.pos)

    local difference = player.pos - coord
    local x, y = difference:abs():comps()
    local newOrientation

    if x > y then
        local newX = sign(difference.x)
        newOrientation = Vec(newX, 0)
    else
        local newY = sign(difference.y)
        newOrientation = Vec(0, newY)
    end

    actor:reorient(newOrientation)
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


return handlers