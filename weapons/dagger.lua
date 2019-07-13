Dagger = Weapon:new{
    xScale = 1 / 24,
    yScale = 1 / 24,
    dmg = 1
}

function Dagger:attemptAttack(dir, t, w, player)

    local x, y = player.x + dir[1], player.y + dir[2]

    if w.entities_grid[x][y] and w.entities_grid[x][y] ~= player then

        self:orient(dir) 

        -- deal damage to the enemy
        w.entities_grid[x][y]:takeHit(player:getAttack())

        self.sprite.x = x
        self.sprite.y = y

        t:setResult('hit')
        
        return w.entities_grid[x][y]
    end

    return false
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
