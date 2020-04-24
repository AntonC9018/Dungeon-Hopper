local Move = require "logic.action.effects.move"
local Bounce = class("Bounce")


function Bounce:__construct(bounceModifier)
    self.distance = bounceModifier.distance or 1
    self.power = bounceModifier.power or 0
end

function Bounce:toMove(direction)
    return Move({ distance = self.distance }, direction)
end

return Bounce