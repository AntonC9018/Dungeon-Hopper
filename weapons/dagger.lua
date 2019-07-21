local Weapon = require('weapons.weapon')

local Dagger = Weapon:new{
    xScale = 1 / 24,
    yScale = 1 / 24,
    dmg = 1,
    pattern = {{ 2, 0 }, { 1, 0 }},
    knockb = {{ 1, 0 }, { 1, 0 }},
    hit_all = false
}

Dagger:loadAssets(assets.Dagger)

function Dagger:new(...)
    local o = Weapon.new(self, ...)
    o:createSprite()
    return o
end



function Dagger:createSprite()
    
    self.sprite = display.newSprite(self.world.group, self.sheet, {
        {
            name = "swipe",
            start = 1,
            count = 3,
            time = 1000,
            loopCount = 1
        }
    }, 1, 1)

    self.sprite.x, self.sprite.y = 1, 1
    self.sprite:scale(self.xScale, self.yScale)
    self.sprite.alpha = 0

    self:listenAlpha()
    
end

-- this is a test
-- the dagger now acts like rapier in CoH
-- function Dagger:modify(obj)
--     local p = obj.pattern
--     local att = obj.attack
--     local w = obj.w
--     local t = obj.t

--     if (p[2] == 1 or p[2] == -1) and p[1] == 1 then
--         att.dmg = att.dmg + 1 
--         att.specials.push_ing = att.specials.push_ing + 1
--         att.specials.push_amount = att.specials.push_amount + 1  
--         obj.owner:thrust(normComps(obj.owner.facing), 1, t, w)
--     end
-- end

return Dagger