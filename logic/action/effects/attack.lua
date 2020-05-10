local Effect = require 'logic.action.effects.effect'
local AttackEffect = class("AttackEffect", Effect)

AttackEffect.modifier = {
    { 'damage', 0 },
    { 'pierce', 0 },
    { 'source', 'normal' },
    { 'power',  1 } -- this is the source power
}

return AttackEffect