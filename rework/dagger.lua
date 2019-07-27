-- local Weapon = require('rework.weapon')

local Dagger = class('Dagger', Weapon)

Dagger.scale = 1 / 24

Dagger.att_base = {
    dmg = 1
}

Dagger.pattern = { { 1, 0 } }
Dagger.knockb = { { 1, 0 } }
Dagger.reach = { false }

Dagger:loadAssets('Dagger')

function Dagger:__construct()
    self:createSprite({
        {
            name = "swipe",
            start = 1,
            count = 3,
            time = 1000,
            loopCount = 1
        }
    })
end