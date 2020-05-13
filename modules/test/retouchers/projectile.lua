local utils = require '@retouchers.utils'

local projectile = {}

local function die(event)
    event.actor:die()
end

projectile.dieBeforeAttack = function(Projectile)
    utils.retouch(Projectile, 'attack', { die, Ranks.HIGHEST })
end

-- Take 1 damage on hit
local function take1damage(event)
    event.actor:takeDamage(1)
    if event.actor.hp:get() <= 0 then
        event.actor:die()
    end
end

projectile.take1damageBeforeAttack = function(Projectile)
    utils.retouch(Projectile, 'attack', { take1damage, Ranks.HIGHEST })
end

-- Be redirected in the opposite direction on hit
-- TODO: Unless hit via the watcher. In that case point in
-- the opposite to the target's movement direction (assume it's their orientation)
local function changeDirection(event)
    event.actor:reorient(-event.action.direction)
end

projectile.changeDirectionBeforeAttack = function(Projectile)
    utils.retouch(Projectile, 'attack', { changeDirection, Ranks.HIGHEST })
end

return projectile