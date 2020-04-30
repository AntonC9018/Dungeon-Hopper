local Weapon = require 'items.weapons.weapon'
local Pattern = require 'items.weapons.pattern'

local pattern = Pattern()
pattern:add( Vec(1, 0), Vec(1, 0), false )
pattern:add( Vec(2, 0), Vec(1, 0), true  )

local Spear = class("Spear", Weapon)

Spear.pattern = pattern


return Spear