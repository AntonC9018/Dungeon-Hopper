local EnvObject = require 'modules.test.base.envobject'
local Entity = require 'logic.base.entity'
local Pierce = require 'modules.test.retouchers.pierce'

local Crate = class('Crate', EnvObject)

Entity.copyChains(EnvObject, Crate)
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