local Effect = require '@action.effects.effect'
local Move = require "@action.effects.move"

local Push = class("Push", Effect)

Push.modifier = {
    { 'distance', 1       },
    { 'power',    0       },
    { 'source',  'normal' }
}

function Push:toMove(direction)
    local move = Move({ distance = self.distance })
    move.direction = direction
    return move
end

return Push