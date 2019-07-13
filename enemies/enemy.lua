
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
    sees = true,
    enemy = true
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
            if ly then table.insert(actions, {  0, -1 }) end
            if gx then table.insert(actions, {  1,  0 }) end
            if lx then table.insert(actions, { -1,  0 }) end
            if gy then table.insert(actions, {  0,  1 }) end
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
            if gy then  table.insert(actions, {  1,  1 }) table.insert(actions, { 0,  1 }) end
            if ly then  table.insert(actions, {  1, -1 }) table.insert(actions, { 0, -1 }) end
                        table.insert(actions, {  1,  0 })
        elseif lx then
            if gy then  table.insert(actions, { -1,  1 }) table.insert(actions, { 0,  1 }) end
            if ly then  table.insert(actions, { -1, -1 }) table.insert(actions, { 0, -1 }) end
                        table.insert(actions, { -1,  0 })
        
        -- on one X with the player
        else
            table.insert(actions, { 0, gy and 1 or -1 })
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

function Enemy:preAnimation()
    if self.dead then
        self:die()
    end
    Entity.preAnimation(self)
end


function Enemy:_idle(t, ts, cb)

    local step = self:getSeqStep()

    if self.close and step.p_close then
        -- play the specified animation
        if step.p_close.anim then
            self:anim(ts, step.p_close.anim)
        end

    elseif self.close_diagonal and step.p_close_diagonal then
        -- play the specified animation
        if step.p_close_diagonal.anim then
            self:anim(ts, step.p_close_diagonal.anim)
        end

    else
        -- play the idle animation
        self:anim(1000, step.anim.idle)
    end

    if cb then cb() end
end


function Enemy:setAction(a, r, w)
    self.moved = true

    -- get the sequence step
    local step = self:getSeqStep()

    -- TODO: probably refactor
    self.close = self:playerClose(w.player)
    self.close_diagonal = self:playerCloseDiagonal(w.player)

    -- reorient to the player if necessary
    if step.reorient then
        self:orientTo(w.player)
    elseif step.p_close and self.close and step.p_close.reorient then
        self:orientTo(w.player)
    end

    -- create the turn
    local t = Turn:new(self, a)

    local M, A, I = contains(step.name, 'move'), contains(step.name, 'attack'), contains(step.name, 'idle')


    if M then

        -- Free way, just move
        if r == FREE then 
            self:go(a, t, w)

        
        elseif r == ENEMY or r == BLOCK then
            self.facing = { a[1], a[2] }
            t:setResult('bumped')
        end
    end

    if A then

        -- damage the player
        if r == PLAYER then
            w.player:takeHit(self)
            self.facing = { a[1], a[2] }
            t:setResult('hit')
        end

    -- elseif contains(step.name, 'break') then
    end

    if I then
        
        t:setResult('idle')

    end
    

    if -- got a custom name of step
        not contains(step.name, 'attack') and 
        not contains(step.name, 'move') and 
        not contains(step.name, 'idle') 
        
        then
            for i = 1, #step.name do
                if self['_f_'..step.name[i]] then
                    -- run the custom function
                    self['_f_'..step.name[i]](self, a, r, t, w, step)
                end
            end

        end

    
    -- save the turn in the history
    table.insert(self.history, t)

end


-- refactor to have an Attack object
function Enemy:takeHit(from)

    print(ins(from))

    -- create the turn
    local t = Turn:new(self, dir)
    t:setResult('hurt')
    table.insert(self.history, t)

    -- stop moving after taking damage?
    if not self.resilient then
        self.moved = true
    end
    -- reset the seq_count?
    if self.weak then
        self.seq_count = 1
    end

    self:loseHP(self:calculateAttack(from))    
    self:applyDebuffs(from)
end


function Enemy:reset()
    self:tickAll()
    self:_reset()
end


-- reset loop logic
function Enemy:_reset()
    -- reset general properties
    Entity.reset(self)
    -- properties specific to enemy
    self.moved = false
    self.cur_actions = false
    self.doing_loop = false
    self.waiting = false

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

-- TODO: update to include different sizes
function Enemy:playerClose(p)
    return 
        (math.abs(p.x - self.x) == 1 and math.abs(p.y - self.y) == 0) or 
        (math.abs(p.x - self.x) == 0 and math.abs(p.y - self.y) == 1)
end

-- TODO: update to include different sizes
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
    if step.loop and self[step.loop](self) then
        next_step = self.seq_count
    elseif 
        -- check if any are specified
        (not step.escape and not step.iterations) or
        -- check the escape condition
        (step.escape and self[step.escape](self)) or
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

    if     player.x > self.x then self.facing =  {  1,  0 }
    elseif player.x < self.x then self.facing =  { -1,  0 }
    elseif player.y > self.y then self.facing =  {  0,  1 }
    elseif player.y < self.y then self.facing =  {  0, -1 }

    -- TODO: give it a random val when no player is around 
    else   self.facing = { 0, 0 } end
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
        -- if s.loop and type(s.loop) == "string" then  
        --     s.loop = self[s.loop]
        -- end
        
        -- if s.escape and type(s.escape) == "string" then  
        --     s.escape = self[s.escape]
        -- end

    end



end


-- make other enemies move if they block way
-- NOTE: for the time being this is not compatible with bigger sizes
-- TODO: fix that
function Enemy:performAction(player_action, w)

    self.doing_action = true

    if not self.sees then
        self.moved = true
        return
    end

    local step = self:getSeqStep()
    local acts = self:getAction(player_action, w)
    local responds = {}

    for i = 1, #acts do
        responds[i] = false
    end

    local i = 0

    -- loop throught all actions
    while(true) do

        i = i + 1
        if i > #acts then break end

        local A = acts[i]

        local x, y = self.x + A[1], self.y + A[2]

        local a, m = contains(step.name, 'attack'), contains(step.name, 'move')

        -- a wall
        if w.walls[x][y] then

            -- if this enemy can destoy the given wall
            if a and self.dig >= w.walls[x][y].dig_res then 
                return self:setAction(A, DIG, w)
            
            -- if can move, bump
            elseif m then
                responds[i] = BLOCK
            end
                
        elseif w.entities_grid[x][y] then

            -- check if it's the player
            if w.entities_grid[x][y] == w.player then

                -- if attacking, attack
                if a then
                    return self:setAction(A, PLAYER, w)
                
                -- if moving, bump
                elseif m then
                    responds[i] = ENEMY
                end

            -- an enemy
            elseif a and A[3] == "attack_fellow" then
                -- attack an enemy? what? why?
                -- TODO: complete this
                self.moved = true

            -- take up the place of a dead enemy
            elseif m and w.entities_grid[x][y].dead then
                return self:setAction(A, FREE, w)


            elseif m and w.entities_grid[x][y].moved == false and 
                -- prevent calling one another in a loop
                -- this can happen if an enemy intends to go back
                not w.entities_grid[x][y].doing_action then
               
                -- make the enemy move
                w.entities_grid[x][y]:selectAction(w)
                -- do the checks for the current iteration again
                i = i - 1
            
            -- attack empty space
            elseif a and not m then
                return self:setAction(A, FREE, w) 
                
            elseif m then
                -- bump into the enemy if there's no better move
                responds[i] = ENEMY
            end


        elseif m then -- free way
            return self:setAction(A, FREE, w)

        else
            -- do user defined special checks
            if self.doSpecialChecks then
                responds[i], ret, rep = self:doSpecialChecks(player_action, w, A)
                if ret then self:setAction(A, responds[i], w) end
                if rep then i = i - 1 end
            else
                return self:setAction(A, FREE, w)
            end
        end

        -- TODO: add projectiles and actions besides these?
    end

    -- if by here it hasn't returned then all actions were meh
    -- in that case just do the first action 
    self:setAction(acts[1], responds[1] or 0, w)
end




