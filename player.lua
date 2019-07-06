

Player = Entity:new{
    scaleX = 60 / 16,
    scaleY = 60 / 16,
    offsetY = -0.4,
    flicker_max = 1,
    flicker_count = 2,
    health = 20,
    last_pos = { 1, 1 },
    last_dir = { 1, 0 },
    to_drop = {}
}

function Player:createSprite()
    self.sprite = display.newSprite(self.sheet, {
        {
            name = "idle",
            start = 1,
            count = 4,
            time = 550,
            loopCount = 0
        },
        {
            name = "jump",
            frames = { 1, 6, 9, 9, 7 },
            time = 1000,
            loopCount = 1
        }
    })
    -- place the sprite in the middle of the screen
    self.sprite.x = display.contentCenterX
    self.sprite.y = display.contentCenterY + UNIT * self.offsetY

    self.sprite:scale(self.scaleX, self.scaleY)
    
    self.sprite:setSequence('idle')
    self.sprite:play()
end

function Player:act(action, g)       

    if action[1] ~= 0 then
        self:orient(action[1])
    end

    self.cur_action, self.last_action = action, self.cur_action

    if action[3] then
        -- special action
        -- self:special(action, x, y, g)
    else 
        if action[1] == nil then
            self:dropBeat() 
        end

        if self:attack(action, g) then return end
        if self:dig(action, g) then return end
        if self:move(action, g) then return end
    end

end

function Player:dropBeat()

end


function Player:dig(dir, g)

    local x, y = self.x + dir[1], self.y + dir[2]

    if g.walls[x][y] then
        g.walls[x][y] = false
        return true
    else 
        return false
    end

end


function Player:attack(dir, g)
    if self.weapon then
        g.attackedEnemy = self.weapon:attemptAttack(dir, g, self)
        if g.attackedEnemy then 
            self.action_name = "idle" 
            return true 
        else
            return false
        end     
    end

    -- if no weapon
    local x, y = self.x + dir[1], self.y + dir[2]

    for i = 1, #g.enemList do
        if g.enemList[i].x == x and g.enemList[i].y == y then 
            g.attackedEnemy = g.enemList[i]
            return false
        end
    end

    return false
end


function Player:move(dir, g)

    if not g.attackedEnemy then 
        if g.walls[self.x + dir[1]][self.y + dir[2]] then
            self.action_name = "bump"
        else
            self.x, self.y = self.x + dir[1], self.y + dir[2] 
            self.action_name = "jump"
        end
    end

    return true
end


function Player:play_animation(g, callback)

    -- get the animation length, 
    -- scale down if there will be more than one animation (bouncing off traps)
    local l = g:getAnimLength()
    local t = #self.bounces and l or l / #self.bounces

    local function _callback(event)
        self.sprite.timeScale = 1
        self.sprite:setSequence('idle')
        self.sprite:play()
        if callback then callback(event) end
    end

    -- recursive bouncing
    local function do_bounces(i)
        i = i + 1     
        
        if self.bounces[i] then
            -- update position
            self.x, self.y = self.x + self.bounces[i][1], self.y + self.bounces[i][2]

            local cb = 
                -- if the last one
                i >= #self.bounces 
                -- call the closing function
                and _callback 
                -- do the next animation
                or function() do_bounces(i) end 

            -- play animation
            self.sprite.timeScale = 1000 / t
            self.sprite:setSequence('jump')
            self.sprite:play()

            if not self.bounces[i][2] then
                -- if hopping to the right or to the left, jump up a little
                transition.to(self.sprite, {
                    y = (self.y - 0.4) * UNIT + display.contentCenterY,
                    transition = easing.continuousLoop,
                    time = t / 2
                })
                transition.to(self.follow_group, {
                    x = (-self.x) * UNIT + display.contentCenterX,
                    transition = easing.inOutQuad,
                    time = t,
                    onComplete = cb
                })            
            else
                transition.to(self.follow_group, {
                    x = (-self.x) * UNIT + display.contentCenterX,
                    y = (-self.y) * UNIT + display.contentCenterY,
                    transition = easing.inOutQuad,
                    time = t,
                    onComplete = cb
                })
            end
        else
            _callback({ phase = "end" })
        end
    end

    if self.action_name == "bump" then
        -- print(ins(self.cur_action))
        -- play animation
        self.sprite.timeScale = 1000 / t
        self.sprite:setSequence('jump')
        self.sprite:play()
        -- hop to and back
        transition.to(self.sprite, {
            x = display.contentCenterX + self.cur_action[1] * UNIT / 2,
            y = display.contentCenterY + self.cur_action[2] * UNIT / 2 + self.offsetY * UNIT,
            transition = easing.continuousLoop,
            time = t / 2,
            onComplete = function() do_bounces(0) end
        })
    elseif self.action_name == "jump" then
        -- play animation
        self.sprite.timeScale = 1000 / t
        self.sprite:setSequence('jump')
        self.sprite:play()
        -- hop onto the tile
        transition.to(self.follow_group, {
            x = -self.x * UNIT + display.contentCenterX,
            y = -self.y * UNIT + display.contentCenterY,
            transition = easing.inOutQuad,
            time = t,
            onComplete = function() do_bounces(0) end
        })
    else
        do_bounces(0)
    end

    if self.weapon then
        self.weapon:play_animation(g)
        self.weapon:play_audio()
    end
end


-- take damage from an enemy
function Player:damage(from)

    -- the palyer is invincible, ignore
    if self.flicker_count <= self.flicker_max then return end
    -- ignore 0 damage
    if from.dmg <= 0 then return end
    -- taking damage drops beat
    self:dropBeat() 
    -- take damage
    self.health = self.health - from.dmg
    -- reset audio
    self.cur_audio = "hurt"

    -- flicker
    self.flicker = transition.to(self.sprite, {
        alpha = 0,
        transition = easing.continuousLoop,
        time = 200,
        iterations = 0
    })
    -- reset fliker count
    self.flicker_count = 0

    return true
end


function Player:equip(weapon)

    table.insert(self.to_drop, self.weapon)
    self.weapon = weapon

    -- play equip sound

end

function Player:reset()
    self.action_name = nil
    self.cur_audio = nil
    self.weapon.action_name  = nil
    self.weapon.cur_audio = nil
    self.attackedEnemy = nil
end