local Projectile = require 'modules.test.base.projectile'
local Combos = require 'modules.test.decorators.combos'
local Proj = require 'modules.test.retouchers.projectile'

local BasicProjectile = class("BasicProjectile", Projectile)

Combos.Projectile(BasicProjectile)
Proj.dieBeforeAttack(BasicProjectile)

return BasicProjectile