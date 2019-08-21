local Weapon = require('base.weapon')

local LongSword = class('LongSword', Weapon)

LongSword.scale = 1 / 24

LongSword.att_base = {
    dmg = 1
}

LongSword.pattern = { vec(1, 0), vec(2, 0) }
LongSword.knockb = { vec(1, 0), vec(1, 0) }
LongSword.reach = { false, 1 }

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

return LongSword