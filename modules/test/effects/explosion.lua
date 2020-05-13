local Effect = require '@action.effects.effect'

local Explode = class("Explode", Effect)

Explode.modifier = {
    -- { 'power',  1 }, -- power is already included in Attack
    { 'radius', 1 }
}

return Explode