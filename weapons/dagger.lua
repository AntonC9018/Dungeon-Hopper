Dagger = Weapon:new{
    xScale = 1 / 24,
    yScale = 1 / 24,
    dmg = 1,
    pattern = {{ 1, 0 }, { 1, 1 }, { 1, -1 }}
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


function Dagger:modify(att, pat, dir, owner)
    if pat[1] == 0 and pat[2] == 2 then   
        owner:applyThrust(norm(dir))
    end
end