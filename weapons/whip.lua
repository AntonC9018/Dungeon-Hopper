local Weapon = require('base.weapon')

local Whip = class('Whip', Weapon)

Whip.scale = 1 / 24

Whip.att_base = {
    dmg = 1
}

Whip.pattern = { vec(1, 0), vec(1, 1), vec(1, -1), vec(1, 2), vec(1, -2) }
Whip.knockb = { vec(1, 0), vec(0, 1), vec(0, -1), vec(0, 1), vec(0, -1) }
Whip.reach = { false, false, false, 2, 3 }

-- function Dagger:__construct(...)
--     Weapon.__construct(self, {
--         {
--             name = "swipe",
--             start = 1,
--             count = 3,
--             time = 1000,
--             loopCount = 1
            
--         }
--     }, ...)
-- end

return Whip