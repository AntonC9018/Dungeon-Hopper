local Projectile = require '.base.projectile'
local Proj = require '.retouchers.projectile'

local BasicProjectile = class("BasicProjectile", Projectile)

copyChains(Projectile, BasicProjectile)
Proj.dieBeforeAttack(BasicProjectile)

return BasicProjectile