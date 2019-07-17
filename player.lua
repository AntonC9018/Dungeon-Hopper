

Player = Entity:new{
    offset_y = -0.4,
    offset_y_jump = -0.2,
    health = 20,
    to_drop = {},
    invincible = 0,
    invincible_max = 2,
    pierce_ing = 1,
    size = { 0, 0 }
}

function Player:createSprite()
    self.sprite = display.newSprite(self.group, self.sheet, {
        {
            name = "idle",
            start = 1,
            count = 4,
            time = 600,
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
    self.sprite.x = self.x
    self.sprite.y = self.y + self.offset_y

    self.sprite:scale(self.scaleX, self.scaleY)
    
    self.sprite:setSequence('idle')
    self.sprite:play()
end

-- a stands for action
-- w stands for world
function Player:act(a, w)     

    local t = Turn:new(self, a)

    self.moved = true

    if a[3] then
        -- special a
        -- self:special(a, w)
    else 
        if a[1] == nil then
            self:dropBeat() 
        end
        -- look to the proper direction
        self.facing = { a[1], a[2] }
        
        
        -- attempt to attack
        local enemy = self:attack(a, t, w)

        -- if attacking set the turn, refresh
        if t._set then
            t:apply()
            t = Turn:new(self, a)
        end

        local wall 

        -- if did not attack or can dig after attacking
        if not enemy or (self.weapon and self.weapon.dig_and_gun) then
            -- attempt to dig
            wall = self:dig(a, t, w)
        end

        -- if digging set the turn, refresh
        if t._set then
            t:apply()
            t = Turn:new(self, a)
        end

        if 
        
        -- if did not attack or can move after attacking 
        (not enemy or (self.weapon and self.weapon.run_and_gun))

        -- and did not dig
        and not dug
        
        then
            self:move(a, t, w)
        end

        -- if moved, add the turn
        if t._set then
            t:apply()
        end

    end
    

end


function Player:dropBeat()
end


-- attempt to attack
function Player:attack(dir, t, w)

    if self.weapon then
        return self.weapon:attemptAttack(dir, t, w, self)
    end

    -- if no weapon
    local x, y = self.x + dir[1], self.y + dir[2]
    
    if w.entities_grid[x][y] and w.entities_grid[x][y] ~= self then         
        t:set('bumped')
        return w.entities_grid[x][y]
    end
end

-- return the attack object
-- modified by items that are on
function Player:getAttack()
    local a = Attack:new()
    a:setDmg(self.dmg)
    a:copyAll(self)
    for i = 1, #self.items do
        self.items[i]:modifyAttack(a)       
    end    
    return a
end

-- attempt to dig
function Player:dig(dir, t, w)

    local x, y = self.x + dir[1], self.y + dir[2]
    
    -- TODO: reconsider 
    if w.walls[x][y] then
        local wall
        wall, w.walls[x][y] = w.walls[x][y], false
        t:set('dug')
        return wall
    end

    return false

end

-- attempt to move
function Player:move(dir, t, w)       
    -- there is no enemies in the way
    if     
        w.entities_grid[self.x + dir[1]][self.y + dir[2]] or 
        w.walls[self.x + dir[1]][self.y + dir[2]]     
    then
        t:set('bumped')
    else
        -- go forward
        self:go(dir, t, w)
    end
end

-- take damage from an enemy
function Player:takeHit(att, w)

    -- create the turn object
    local t = Turn:new(self, false)    

    -- apply pushing etc
    self:applySpecials(att, t, w)

    -- if pushed or something
    if t._set then
        t:apply()
    end
    
    -- the palyer is invincible, ignore
    if self.invincible > 0 then return end

    -- calculate the attack damage
    local dmg = self:calculateAttack(att) 

    -- ignore 0 damage
    if dmg <= 0 then return end
    
    
    -- taking damage drops beat
    self:dropBeat() 

    -- take damage
    self:loseHP(dmg)    
    -- apply debuffs etc
    self:applyDebuffs(att, w)
    
    t:set('hurt')  

    -- insert the turn if it hasn't been inserted already
    if not contains(self.history, t) then
        t:apply()
    end


    -- start flickering
    self.flicker = transition.to(self.sprite, {
        alpha = 0,
        transition = easing.continuousLoop,
        time = 200,
        iterations = 0
    })
    -- reset fliker count
    self.invincible = self.invincible_max

    return true
end


-- equipping a weapon 
-- TODO: or an item
function Player:equip(weapon)

    table.insert(self.to_drop, self.weapon)
    self.weapon = weapon

    -- TODO: refactor
    self.dmg = weapon.dmg

    -- play equip sound

end


-- function called before playAnimation()
function Player:preAnimation(w)
    Entity.preAnimation(self)
    -- make the world (the camera) follow the player
    self:syncCamera(w:getAnimLength(), nil, self.x, self.y)
end


function Player:syncCamera(...)
    self.camera:sync(self, ...)
end


-- for now
function Player:_hurt(t, ts, cb)
    self:playAudio('hurt')
    if cb then cb() end
end


function Player:_hit(t, ts, cb)
    self.weapon:play_animation(ts)
    self.weapon:playAudio()
    if cb then cb() end
end


function Player:_dashedHit(t, ts, cb)
    self:_hit(t, ts)
    self:_displaced(t, ts, cb)
end

function Player:_dug(t, ts, cb)
    self:playAudio('dig')
    if cb then cb() end
end


function Player:reset()
    self.attacked_enemy = false
    Entity.tickAll(self)

    -- stop flickering
    if self.invincible <= 0 and self.flicker then
        -- stop flickering
        transition.cancel(self.flicker)
        -- restore alpha
        transition.to(self.sprite, {
            alpha = 1,
            time = 100
        })
        self.sprite.alpha = 1
    end

    Entity.reset(self)
end
