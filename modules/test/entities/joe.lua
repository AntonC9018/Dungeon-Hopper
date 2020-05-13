local Player = require '.base.player'

local Joe = class('Joe', Player)

-- Entity.copyChains(EnvObject, Joe)

Joe.baseModifiers = {
    hp = {
        amount = 100
    },
    attack = {
        damage = 1,
        pierce = 2        
    }
}

return Joe