local Chain = require "lib.chains.chain"
local Special = require "logic.action.actions.special"

local Seq = {}


Seq.specialActionFromHandler = function(name, handler)
    local chain = Chain()
    chain:addHandler(handler)
    local specialClass = class(name, Special)
    specialClass.chain = chain
    return specialClass
end



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


Seq.handlers = handlers


return Seq