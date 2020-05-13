local EnvObject = require '.base.envobject'
local Entity = require '@base.entity'
local Pierce = require '.retouchers.pierce'

local Crate = class('Crate', EnvObject)

copyChains(EnvObject, Crate)
-- set our pierce to 0 when attacked if attack damage is greater than 3
Pierce.removeIfDamageAbove(Crate, 3)

Crate.baseModifiers = {
    hp = {
        amount = 1
    },
    resistance = {
        push = 0,
        pierce = 1
    }
}

return Crate