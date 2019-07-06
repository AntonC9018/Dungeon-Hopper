Dagger = Entity:new{
    dmg = 1,
    xScale = 1 / 24,
    yScale = 1 / 24
}

function Dagger:attemptAttack(dir, g, player)

    local x, y = player.x + dir[1], player.y + dir[2]

    if g.enemGrid[x][y] and g.enemGrid[x][y] ~= player then

        self:orient(dir)  

        self.action_name = "swipe"
        self.cur_audio = "swipe"

        -- deal damage to the enemy
        g.enemGrid[x][y]:damage(dir, self.dmg)

        self.sprite.x = x
        self.sprite.y = y

        return g.enemGrid[x][y]
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

    self.sprite:addEventListener("sprite", function(event)
        print('Swiping')
        if event.phase == "began" then
            self.sprite:toFront()
            self.sprite.alpha = 1
        elseif event.phase == "ended" then
            self.sprite.alpha = 0
        end
    end) 
end


function Dagger:orient(dir)

    if          dir[1] ==  1 then self.sprite.rotation = 0
       elseif   dir[1] == -1 then self.sprite.rotation = 180
       elseif   dir[2] ==  1 then self.sprite.rotation = 90
       elseif   dir[2] == -1 then self.sprite.rotation = 270 
       else self.sprite.rotation = 0 end       
end