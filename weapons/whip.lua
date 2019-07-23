local Weapon = require('weapons.weapon')

local Whip = Weapon:new{
    xScale = 1 / 24,
    yScale = 1 / 24,
    dmg = 1,
    pattern = { { 1, 0 }, { 1, 1 }, { 1, -1 }, { 1, 2 }, { 1, -2 } },
    knockb = { { 1, 0 }, { 0, 1 }, { 0, -1 }, { 0, 1 }, { 0, -1 } },
    reach = { 1, 0 },
    hit_all = false
}

Whip:loadAssets(assets.Dagger)

function Whip:new(...)
    local o = Weapon.new(self, ...)
    o:createSprite()
    return o
end



function Whip:createSprite()
    
    self.sprite = display.newSprite(self.world.group, self.sheet, {
        {
            name = "swipe",
            start = 1,
            count = 3,
            time = 1000,
            loopCount = 1
        }
    }, 1, 1)
    self.sprite:scale(self.xScale, self.yScale)
    self.sprite.alpha = 0
    self:listenAlpha()
end

return Whip