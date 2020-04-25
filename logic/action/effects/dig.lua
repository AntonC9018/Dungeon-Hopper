local Effect = require 'logic.action.effects.effect'

local DigEffect = class("DigEffect", Effect)

DigEffect.modifier = {
    { 'damage', 0 },
    { 'power', 0 }
}

return DigEffect