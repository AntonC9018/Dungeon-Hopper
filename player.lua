

Player = Entity:new{
    scaleX = 60 / 16,
    scaleY = 60 / 16,
    offset_y = -0.4,
    offset_y_jump = -0.2,
    health = 20,
    to_drop = {},
    bounces = {},
    invincible = 0,
    invincible_max = 1,
    pierce_ing = 1
}

function Player:createSprite()
    self.sprite = display.newSprite(self.sheet, {
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
    self.sprite.x = display.contentCenterX
    self.sprite.y = display.contentCenterY + UNIT * self.offset_y

    self.sprite:scale(self.scaleX, self.scaleY)
    
    self.sprite:setSequence('idle')
    self.sprite:play()
end


function Player:act(action, w)     

    self.cur_a = action

    if action[3] then
        -- special action
        -- self:special(action, w)
    else 
        if action[1] == nil then
            self:dropBeat() 
        end
        -- look to the proper direction
        self.facing = { action[1], action[2] }
        -- attempt to attack
        if self:attack(action, w) then return end
        -- attempt to dig
        if self:dig(action, w) then return end
        -- attampt to move
        if self:move(action, w) then return end
    end

end


function Player:dropBeat()

end


function Player:dig(dir, w)

    local x, y = self.x + dir[1], self.y + dir[2]
    
    -- TODO: consider 
    if w.walls[x][y] then
        w.walls[x][y] = false
        self.dug = true
        return true
    else 
        return false
    end

end


function Player:attack(dir, w)
    if self.weapon then
        w.attacked_enemy = self.weapon:attemptAttack(dir, w, self)
        if w.attacked_enemy then 
            self.hit = true 
            return true 
        else
            return false
        end     
    end

    -- if no weapon
    local x, y = self.x + dir[1], self.y + dir[2]
    
    if w.enemGrid[x][y] and w.enemGrid[x][y] ~= self then 
        w.attacked_enemy = w.enemGrid[x][y]
        self.bumped = true
        return false
    end

    return false
end


function Player:move(dir, w)

    if not w.attacked_enemy then 
        if w.walls[self.x + dir[1]][self.y + dir[2]] then
            self.bumped = true
        else
            self.x, self.y = self.x + dir[1], self.y + dir[2] 
            self.displaced = true
        end
    end

    return true
end



function Player:play_animation(w, callback)
    -- get the animation length, 
    -- scale down if there will be more than one animation (bouncing off traps)
    local l = w:getAnimLength()
    local t = #self.bounces and l or (l + 1) / #self.bounces


    -- look in the proper direction
    if self.cur_a[1] ~= 0 then
        self:orient(self.cur_a[1])
    end

    local function _callback(event)
        self:anim(1000, 'idle')
        if callback then callback(event) end
    end

    -- recursive bouncing
    -- TODO: REFACTOR
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
            self:anim(t, 'jump')

            if not self.bounces[i][2] then
                -- if hopping to the right or to the left, jump up a little
                self:trans({
                    y = (self.y + self.offset_y_jump + self.offset_y) * UNIT + display.contentCenterY,
                    transition = easing.continuousLoop,
                    time = t / 2
                })
                self:transGroup({
                    x = (-self.x) * UNIT + display.contentCenterX,
                    transition = easing.inOutQuad,
                    time = t,
                    onComplete = cb
                })            
            else
                self:transGroup({
                    x = (-self.x) * UNIT + display.contentCenterX,
                    y = (-self.y) * UNIT + display.contentCenterY,
                    transition = easing.inOutQuad,
                    time = t,
                    onComplete = cb
                })
            end
        else -- if not self.bounces[i]
            _callback({ phase = "end" })
        end
    end
    
    

    if self.hurt then
        -- TODO: play hurt animation
        self:anim(t, 'idle')

        self:play_audio('hurt')
    end

    if self.hit then
        -- play the weapon animation animation
        self.weapon:play_animation(l)
        self.weapon:play_audio()

        -- TODO: add a hit animation
        -- self:anim('hit')
        self:anim(t, 'idle')

        -- TODO: add a hitting sound
        -- self:play_audio('hit')

        -- no transition on sprite is happenning, but the callback
        -- must be called in time. Offset bounces by t
        timer.performWithDelay(t, function() do_bounces(0) end, 1)


    elseif self.dug then
        -- TODO: play spade animation?
        -- TODO: add a digging animation
        -- self:anim('dig')

        -- TODO: sound
        self:play_audio('dig')


        timer.performWithDelay(t, function() do_bounces(0) end, 1)


    elseif self.displaced then
        -- play the jumping animation
        self:anim(t, 'jump')

        -- transition of the world
        self:syncGroup(t, do_bounces)

        -- transition of own sprite
        -- hop up a bit
        self:hopUp(t)



    elseif self.bumped then
        -- TODO: add bumping animation?
        self:anim(1000 / t, 'jump')

        self:transBump(t, do_bounces)
    else

        timer.performWithDelay(t, function() do_bounces(0) end, 1)

    end
end


-- take damage from an enemy
function Player:takeHit(from)

    -- the palyer is invincible, ignore
    if self.invincible > 0 then return end
    -- ignore 0 damage
    if from.dmg <= 0 then return end
    -- taking damage drops beat
    self:dropBeat() 
    -- take damage
    self.health = self.health - from.dmg

    self.hurt = true

    -- flicker
    self.flicker = transition.to(self.sprite, {
        alpha = 0,
        transition = easing.continuousLoop,
        time = 200,
        iterations = 0,
        tag = 'flicker'
    })
    -- reset fliker count
    self.invincible = self.invincible_max

    return true
end


function Player:equip(weapon)

    table.insert(self.to_drop, self.weapon)
    self.weapon = weapon

    -- TODO: refactor
    self.dmg = weapon.dmg

    -- play equip sound

end


function Player:transGroup(o)
    transition.to(self.follow_group, o)
end

function Player:reset()
    self.attacked_enemy = false
    Entity.reset(self)
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
    Entity.tickAll(self)

end

function Player:tickAll()
end

function Player:syncGroup(t, cb)
    transition.to(self.follow_group, {
        x = -self.x * UNIT + display.contentCenterX,
        y = -self.y * UNIT + display.contentCenterY,
        transition = easing.inOutQuad,
        time = t,
        onComplete = function() if cb then cb(0) end end
    })
end

function Player:transBump(t, cb, x, y, dir)
    transition.to(self.sprite, {
        x = display.contentCenterX + ((x or -self.x) + (dir and dir[1] or self.cur_a[1]) / 2) * UNIT,
        y = display.contentCenterY + ((y or -self.y) + self.offset_y_jump + self.offset_y + (dir and dir[2] or self.cur_a[2]) / 2) * UNIT,
        transition = easing.continuousLoop,
        time = t / 2,
        onComplete = function() if cb then cb(0) end end
    })
end


function Player:hopUp(t, cb)
    transition.to(self.sprite, {
        y = display.contentCenterY + (self.offset_y_jump + self.offset_y) * UNIT,
        transition = easing.continuousLoop,
        time = t / 2,
        onComplete = function() if cb then cb(0) end end
    })
end