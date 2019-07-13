Dagger = Weapon:new{
    xScale = 1 / 24,
    yScale = 1 / 24,
    dmg = 1,
    pattern = {{ 1, 0 }, { 1, 1 }, { 1, -1 }, { 2, 0 }}
}


function Dagger:createSprite()
    
    self.sprite = display.newSprite(self.group, self.sheet, {
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

    self:listenAlpha()
    
end

-- this is a test
-- the dagger now acts like rapier in CoH
function Dagger:modify(att, pat, owner, w)
    if pat[2] == 0 and pat[1] == 2 then
        att.dmg = att.dmg + 1 
        att.specials.push_ing = att.specials.push_ing + 1
        att.specials.push_amount = att.specials.push_amount + 1  
        owner:thrust(normComps(att.dir), 1, w)
    end
end