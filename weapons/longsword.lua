local Weapon = require('base.weapon')

local LongSword = class('LongSword', Weapon)

LongSword.scale = 1 / 24

LongSword.att_base = {
    dmg = 1
}

LongSword.pattern = { Vec(1, 0), Vec(2, 0) }
LongSword.knockb = { Vec(1, 0), Vec(1, 0) }
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