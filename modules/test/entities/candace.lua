local Player = require '.base.player'

local Candace = class('Candace', Player)

-- Entity.copyChains(EnvObject, Joe)

Candace.baseModifiers = {
    hp = {
        amount = 100
    },
    attack = {
        damage = 1,
        pierce = 2        
    }
}

return Candace