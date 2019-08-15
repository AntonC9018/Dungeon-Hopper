local Weapon = require('base.weapon')

local Dagger = class('Dagger', Weapon)

Dagger.scale = 1 / 24

Dagger.att_base = {
    dmg = 1
}

Dagger.pattern = { vec(1, 0), vec(2, 0) }
Dagger.knockb = { vec(1, 0), vec(1, 0) }
Dagger.reach = { false, 1 }

function Dagger:__construct(...)
    Weapon.__construct(self, {
        {
            name = "swipe",
            start = 1,
            count = 3,
            time = 1000,
            loopCount = 1
            
        }
    }, ...)
end

return Dagger