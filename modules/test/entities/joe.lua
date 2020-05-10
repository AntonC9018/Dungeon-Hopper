local EnvObject = require 'modules.test.base.envobject'
local Entity = require 'logic.base.entity'
local Player = require 'modules.test.base.player'
local Pierce = require 'modules.test.retouchers.pierce'

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