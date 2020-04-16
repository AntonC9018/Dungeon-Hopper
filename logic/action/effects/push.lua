local Move = require "logic.actions.effects.move"
local Push = class("Push")


function Push:__construct(pushModifier)
    self.distance = pushModifier.distance or 1
    self.power = pushModifier.power or 0
end

function Push:toMove(direction)
    return Move({ distance = self.distance }, direction)
end

return Push