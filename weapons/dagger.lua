Dagger = Weapon:new{
    xScale = 1 / 24,
    yScale = 1 / 24,
    dmg = 1
}

function Dagger:attemptAttack(dir, w, player)

    local x, y = player.x + dir[1], player.y + dir[2]

    if w.enemGrid[x][y] and w.enemGrid[x][y] ~= player then

        self:orient(dir) 

        -- deal damage to the enemy
        w.enemGrid[x][y]:takeHit(dir, player)

        self.sprite.x = x
        self.sprite.y = y

        return w.enemGrid[x][y]
    end

end


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
