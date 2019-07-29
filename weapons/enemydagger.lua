local EnemyWeapon = require('base.enemyweapon')

local EnemyDagger = class('EnemyDagger', EnemyWeapon)

EnemyDagger.scale = 1 / 24

function EnemyDagger:__construct(...)
    EnemyWeapon.__construct(self, {
        {
            name = "swipe",
            start = 1,
            count = 3,
            time = 1000,
            loopCount = 1
        }
    }, ..., 'Dagger')
end

return EnemyDagger