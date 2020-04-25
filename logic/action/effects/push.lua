local Effect = require 'logic.action.effects.effect'
local Move = require "logic.action.effects.move"

local Push = class("Push", Effect)

Push.modifier = {
    { 'distance', 1 },
    { 'power',    0 }
}

function Push:toMove(direction)
    return Move({ distance = self.distance }, direction)
end

return Push