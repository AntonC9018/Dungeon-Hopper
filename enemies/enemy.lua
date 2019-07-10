
-- HOR_VER = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
-- DIAGONAL = { { 1, 1 }, { -1, -1 }, { -1, 1 }, { 1, -1 } }

-- movement types
-- "basic" = 1 -- basic right left up down (orthogonal) movement towards player
-- "diagonal" = 2 -- diagonal movement towards player
-- "straight" = 3 -- go in a straight line
-- "adjacent" = 4 -- go vertically, horizontally or diagonally towards player


Enemy = Entity:new{
    facing = { 1, 0 },
    dmg = 1,
    max_vision = 6,
    health = 3,
    sees = true
}

-- whether to reset the sequence step to 1 after being attacked
Enemy.weak = true
-- whether to move even after taking damage
Enemy.resilient = false
-- whether done something on this game loop
-- Enemy.move = false
-- how far each step is
Enemy.reach = 1


-- abstract
function Enemy:createSprite() end


-- get a list of desirable actions sorted by priority
function Enemy:getAction(player_action, w)    
    if not self.cur_actions then
        self:computeAction(player_action, w)
    end
    return self.cur_actions
end


-- figure out next movement
function Enemy:computeAction(player_action, w)

    local actions = {}

    if not self:getSeqStep().mov then self.cur_actions = actions

    -- got a custom table of actions
    elseif type(self:getSeqStep().mov) == 'table' then

        actions = self:getSeqStep().mov
    
    -- Basic orthogonal movement
    elseif self:getSeqStep().mov == "basic" then
        local gx, gy = w.player.x > self.x, w.player.y > self.y
        local lx, ly = w.player.x < self.x, w.player.y < self.y


        -- So this is basically if-you-look-to-the-left,- 
        -- you-would-prefer-to-go-to-the-left action

        if self.facing[1] > 0 then -- looking right
            -- prioritize going to the right
            if gx then table.insert(actions, {  1,  0 }) end
            if gy then table.insert(actions, {  0,  1 }) end
            if ly then table.insert(actions, {  0, -1 }) end
            if lx then table.insert(actions, { -1,  0 }) end
        elseif self.facing[1] < 0 then -- looking left
            -- prioritize going to the left
            if lx then table.insert(actions, { -1,  0 }) end
            if gy then table.insert(actions, {  0,  1 }) end
            if ly then table.insert(actions, {  0, -1 }) end
            if gx then table.insert(actions, {  1,  0 }) end
        elseif self.facing[2] > 0 then -- looking down
            --- ...
            if gy then table.insert(actions, {  0,  1 }) end
            if gx then table.insert(actions, {  1,  0 }) end
            if lx then table.insert(actions, { -1,  0 }) end
            if ly then table.insert(actions, {  0, -1 }) end
        elseif self.facing[2] < 0 then -- looking up
            --- ...
            if gy then table.insert(actions, {  0,  1 }) end
            if gx then table.insert(actions, {  1,  0 }) end
            if lx then table.insert(actions, { -1,  0 }) end
            if ly then table.insert(actions, {  0, -1 }) end
        else -- no direction. Default order!
            -- ...
            if gx then table.insert(actions, {  1,  0 }) end
            if lx then table.insert(actions, { -1,  0 }) end
            if gy then table.insert(actions, {  0,  1 }) end
            if ly then table.insert(actions, {  0, -1 }) end
        end

    
    elseif self:getSeqStep().mov == "diagonal" then

        local gx, gy = w.player.x > self.x, w.player.y > self.y
        local lx, ly = w.player.x < self.x, w.player.y < self.y

        -- to the left of the player
        if gx then
            if     gy then table.insert(actions, { 1,  1 }) 
            elseif ly then table.insert(actions, { 1, -1 })
            else
                -- we're on one X with the player 
                if self.facing[2] > 0 then
                    table.insert(actions, { 1,  1 })
                    table.insert(actions, { 1, -1 })
                else
                    table.insert(actions, { 1, -1 })
                    table.insert(actions, { 1,  1 })
                end
            end

        -- to the right of the player
        elseif lx then
            if     gy then table.insert(actions, { -1,  1 }) 
            elseif ly then table.insert(actions, { -1, -1 })
            else
                -- we're on one X with the player
                if self.facing[2] > 0 then
                    table.insert(actions, { -1,  1 })
                    table.insert(actions, { -1, -1 })
                else
                    table.insert(actions, { -1, -1 })
                    table.insert(actions, { -1,  1 })
                end
            end

        -- on one Y with the player
        -- higher than the player
        elseif gy then
            if self.facing[1] > 0 then
                table.insert(actions, { -1,  1 })
                table.insert(actions, {  1,  1 })
            else
                table.insert(actions, {  1,  1 })
                table.insert(actions, { -1,  1 })
            end 

        -- lower than the player
        else
            if self.facing[1] > 0 then
                table.insert(actions, { -1, -1 })
                table.insert(actions, {  1, -1 })
            else
                table.insert(actions, {  1, -1 })
                table.insert(actions, { -1, -1 })
            end 
        end


    elseif self:getSeqStep().mov == "adjacent" then

        local gx, gy = w.player.x > self.x, w.player.y > self.y
        local lx, ly = w.player.x < self.x, w.player.y < self.y

        if gx then
            if gy then  table.insert(actions, {  1,  1 }) end
            if ly then  table.insert(actions, {  1, -1 }) end
                        table.insert(actions, {  1,  0 })
        elseif lx then
            if gy then  table.insert(actions, { -1,  1 }) end
            if ly then  table.insert(actions, { -1, -1 }) end
                        table.insert(actions, { -1,  0 })
        
        -- on one X with the player
        else
            table.insert(actions, { 0, gy and 1 or -1 })
        end

    -- same adjacent, but if bumping into an enemy by going diagonally
    -- it would compromise by going straight down/up or left/right towards the player
    elseif self:getSeqStep().mov == "adjacent-smart" then

        local gx, gy = w.player.x > self.x, w.player.y > self.y
        local lx, ly = w.player.x < self.x, w.player.y < self.y

        -- to the right of the player
        if gx then
            if gy then  
                table.insert(actions, {  1,  1 }) 
                table.insert(actions, {  1,  0 })
                table.insert(actions, {  1, -1 })
            elseif ly then  
                table.insert(actions, {  1, -1 })
                table.insert(actions, {  1,  0 })
                table.insert(actions, {  1,  1 }) 
            else
                table.insert(actions, {  1,  0 })
                table.insert(actions, {  1, -1 })
                table.insert(actions, {  1,  1 })
            end
        -- to the left of the player
        elseif lx then
            if gy then  
                table.insert(actions, { -1,  1 }) 
                table.insert(actions, { -1,  0 })
                table.insert(actions, { -1, -1 })
            elseif ly then  
                table.insert(actions, { -1, -1 })
                table.insert(actions, { -1,  0 })
                table.insert(actions, { -1,  1 }) 
            else
                table.insert(actions, { -1,  0 })
                table.insert(actions, { -1, -1 })
                table.insert(actions, { -1,  1 })
            end
        -- on the same X with the player
        else
            if gy then
                table.insert(actions, {  0,  1 })
                table.insert(actions, {  1,  1 })
                table.insert(actions, { -1,  1 })
            else
                table.insert(actions, {  0,  1 })
                table.insert(actions, { -1,  1 })
                table.insert(actions, {  1,  1 })
            end
        end

    -- please don't use these random ones. These would be very obnoxious to deal with
    elseif self:getSeqStep().mov == "basic-random" then
        local x = math.random(0, 1) * 2 - 1
        local i = math.random(1, 2)
        local t = { 0, 0 }
        t[i] = x
        table.insert(actions, t)
    
    elseif self:getSeqStep().mov == "diagonal-random" then
        table.insert(math.random(0, 1) * 2 - 1, math.random(0, 1) * 2 - 1)


    elseif self:getSeqStep().mov == "adjacent-random" then
        table.insert(math.random(-1, 1), math.random(-1, 1))


    -- move continuously in a straight line
    elseif self:getSeqStep().mov == "straight" then
        table.insert(actions, { self.facing[1], self.facing[2] })
    end

    self.cur_actions = actions
end


function Enemy:playAnimation(w)   

    if self.dead then
        self:die()
        return 
    end

    -- get the sequence step
    local step = self:getSeqStep()

    -- get the time of animations and transitions
    local l = w:getAnimLength()
    local t = #self.bounces and l or l / #self.bounces

    -- change orientation
    if self.facing[1] ~= 0 then
        self:orient(self.facing[1])
    end

    -- the enemy does nothing
    if contains(step.name, "idle") then

        -- this can only be true if a p_close if specified
        if self.close and step.p_close then
            -- play the specified animation
            if step.p_close.anim then
                self:anim(t, step.p_close.anim)
            end

        elseif self.close_diagonal and step.p_close_diagonal then
            -- play the specified animation
            if step.p_close_diagonal.anim then
                self:anim(t, step.p_close_diagonal.anim)
            end

        else
            -- play the idle animation
            self:anim(t, step.anim.idle)
        end

    else

        if contains(step.name, 'attack') then

            if self.hit then
                -- play hit animation
                self:anim(t, step.anim.attack)
                -- jump to and back
                self:transAttack(t)
                return
            end

        end

        if contains(step.name, 'move') then

            if self.displaced then
                self:anim(t, step.anim.move)
                self:transJump(t)
            
            elseif self.bumped then
                self:anim(t, step.anim.move)
                self:transBump(t)
            end

        end



    end
end




function Enemy:setAction(a, r, w)
    -- "Current action"
    self.cur_a = a
    -- "Response to the current action"
    self.cur_r = r
    -- get the sequence step
    local step = self:getSeqStep()

    -- TODO: probably refactor
    self.close = self:playerClose(w.player)
    self.close_diagonal = self:playerCloseDiagonal(w.player)

    if step.reorient then

        self:orientTo(w.player)

    end

    if contains(step.name, 'move') then

        -- Free way, just move
        if r == FREE then
            self.x = a[1] + self.x
            self.y = a[2] + self.y
            if not step.reorient then self.facing = { a[1], a[2] } end
            self.displaced = true
        
        elseif r == ENEMY or r == BLOCK then
            if not step.reorient then self.facing = { a[1], a[2] } end
            self.bumped = true
        end
    end

    if contains(step.name, 'attack') then

        -- damage the player
        if r == PLAYER then
            w.player:takeHit(self)
            if not step.reorient then self.facing = { a[1], a[2] } end
            self.hit = true
            print('hit true')
        end

    -- elseif contains(step.name, 'break') then
    end
    

    if -- got a custom name of step
        not contains(step.name, 'attack') and 
        not contains(step.name, 'move') and 
        not contains(step.name, 'idle') 
        
        then
            for i = 1, #step.name do
                if self['_f'..step.name[i]] then
                    -- run the custom function
                    self['_f'..step.name[i]](self, a, r, w, step)
                end
            end

        end

end



function Enemy:takeHit(dir, from)
    -- stop moving after taking damage?
    if not self.resilient then
        self.moved = true
    end
    self.hurt = true

    self:loseHP(self:calculateAttack(from))    
    self:applyDebuffs(from)
end




-- reset loop logic
function Enemy:reset()
    -- reset general properties
    Entity.reset(self)
    -- properties specific to enemy
    self.moved = false
    self.cur_r = false
    self.cur_actions = false
end


function Enemy:tickAll()
    self:updateSeq()
    Entity.tickAll(self)
end

function Enemy:die()
    transition.to(self.sprite, {
        alpha = 0,
        time = 600,
        transition = easing.linear,
        onComplete = function()
            display.remove(self.sprite)
        end
    })
end

function Enemy:playerClose(p)
    return 
        (math.abs(p.x - self.x) == 1 and math.abs(p.y - self.y) == 0) or 
        (math.abs(p.x - self.x) == 0 and math.abs(p.y - self.y) == 1)
end


function Enemy:playerCloseDiagonal(p, dir)
    return math.abs(p.x - self.x) == 1 and math.abs(p.y - self.y) == 1
end

function Enemy:getSeqStep()
    return self.sequence[self.seq_count]
end

function Enemy:updateSeq()
    local step = self:getSeqStep()

    local next_step

    -- check loop condition. Keep playing if active
    if step.loop and step.loop(self) then
        next_step = self.seq_count
    elseif 
        -- check if any are specified
        (not step.escape and not step.iterations) or
        -- check the escape condition
        (step.escape and step.escape(self)) or
        -- check the iterations condition
        (step.iterations and self.iterations >= step.iterations) then


        -- figure out what step we will go to
        -- check if a to_step is specified inside p_close or p_close_diagonal
        if self.close and step.p_close and step.p_close.to_step then 
            next_step = step.p_close.to_step

        elseif self.close_diagonal and step.p_close_diagonal and step.p_close_diagonal.to_step then
            next_step = step.p_close_diagonal

        -- check if a to_step is specified outside those
        elseif step.to_step then
            next_step = step.to_step

        -- check if a random step should be used
        elseif step.to_random and #step.to_random > 0 then
            next_step = step.to_random[math.random(1, #step.to_random)]

        -- otherwise just add one
        else
            next_step = self.seq_count + 1
        end


    else
        next_step = self.seq_count + 1
    end

    self.seq_count = next_step > #self.sequence and (next_step - #self.sequence) or next_step
end


-- change the facing to the player if not facing them already
function Enemy:orientTo(player)
    if self.facing[1] > 0 and player.x > self.x or
       self.facing[1] < 0 and player.x < self.x or
       self.facing[2] > 0 and player.y > self.y or
       self.facing[2] < 0 and player.y < self.y then return end

    if     player.x > self.x then self.facing[1] =  1
    elseif player.x < self.x then self.facing[1] = -1
    elseif player.y > self.y then self.facing[2] =  1
    elseif player.y < self.y then self.facing[2] = -1

    -- TODO: give it a random val when no player is around 
    else   self.facing = { 0, 0 } end
end


-- functions that define basic transitions
function Enemy:transAttack(...)
    self:transBump(...)
end

function Enemy:transBump(t, cb, x, y, dir)
    transition.to(self.sprite, { 
        x = (x or self.x) + (dir and dir[1] or self.cur_a[1]) / 2, 
        y = (y or self.y) + (dir and dir[2] or self.cur_a[2]) / 2 + self.offset_y + self.offset_y_jump,
        time = t / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb(0) end end
    })
end

function Enemy:transJump(t, cb, x, y, dir)
    transition.to(self.sprite, {
        x = (x or self.x),
        y = (y or self.y) + self.offset_y,
        time = t,
        transition = easing.inOutQuad,
        onComplete = function() if cb then cb(0) end end
    })
    transition.to(self.sprite, {
        y = (y or self.y) + self.offset_y + self.offset_y_jump,
        time = t / 2,
        transition = easing.continuousLoop
    })
end


function Enemy:transformSequence()

    for i = 1, #self.sequence do
        local s = self.sequence[i]
        local names = type(s.name) == 'table' and s.name or {s.name}
        local anims = {}
        if s.anim then
            if type(s.anim) == 'string' then
                for j = 1, #names do
                    anims[names[j]] = s.anim
                end
            else
                for j = 1, #names do
                    anims[names[j]] = s.anim[j] or s.anim[names[j]]
                end
            end
        else
            for j = 1, #names do
                anims[names[j]] = names[j]
            end
        end

        s.name = names
        s.anim = anims


        -- convert "loop" and "escape" strings into functions
        if s.loop and type(s.loop) == "string" then  
            local str = string.sub(s.loop, 1)
            s.loop = function(e) return e[str] end
        end
        
        if s.escape and type(s.escape) == "string" then  
            local str = string.sub(s.escape, 1)
            s.escape = function(e) return e[str] end
        end

    end



end