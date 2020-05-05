local Effect = require 'logic.action.effects.effect'

local Bounce = class("Bounce", Effect)

Bounce.modifier = {
    { 'power',  1 },
    { 'radius', 1 }
}

return Bounce