local EnvObject = require 'modules.test.base.envobject'
local Entity = require 'logic.base.entity'
local Player = require 'modules.test.base.player'
local Pierce = require 'modules.test.retouchers.pierce'

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