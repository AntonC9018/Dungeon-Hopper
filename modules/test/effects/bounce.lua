local Move = require "logic.action.effects.move"
local Effect = require 'logic.action.effects.effect'

local Bounce = class("Bounce", Effect)

Bounce.modifier = {
    { 'distance', 1 },
    { 'power',    0 }
}

function Bounce:toMove(direction)
    local move = Move({ distance = self.distance })
    move.direction = direction
    return move
end

return Bounce