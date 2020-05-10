local Projectile = require 'modules.test.base.projectile'
local Proj = require 'modules.test.retouchers.projectile'
local Entity = require 'logic.base.entity'

local BasicProjectile = class("BasicProjectile", Projectile)

Entity.copyChains(Projectile, BasicProjectile)
Proj.dieBeforeAttack(BasicProjectile)

return BasicProjectile