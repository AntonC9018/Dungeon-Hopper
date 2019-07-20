
local Turn = require('turn')
local Entity = require('entity')

local Enemy = Entity:new{
    dmg = 1,
    max_vision = 6,
    health = 1,
    sees = true,
    enemy = true,
    size = { 0, 0 },
    seq_count = 1,
    priority = 1
}

function Enemy:new(...)
    local o = Entity.new(self, unpack(arg))
    o:on('animation:start', function() if o.dead then o:_die() end end)

    o:on('hurt:start', function() 
        -- stop moving after taking damage?
        if not o.resilient then
            o.moved = true
        end
        -- reset the seq_count?
        if o.weak then
            o.seq_count = 1
        end
    end)

    
    return o
end

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

    self.emitter:emit('computeAction:start', self, player_action)
    

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
    -- at least make the enemies point in the direction they are going to move
    -- like bats in CoH as opposed to the bats of CotND
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

    self.emitter:emit('computeAction:end', self, actions)
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


    -- create the turn
    local t = Turn:new(self, a)

    self.emitter:emit('setAction:start', self, a, r, t)

    local M, A, I = contains(step.name, 'move'), contains(step.name, 'attack'), contains(step.name, 'idle')

    if not t._set then

        if M then

            -- Free way, just move
            if r == 'free' then 
                self:go(a, t, w)

            
            elseif r == 'enemy' or r == 'block' then
                self.facing = { a[1], a[2] }
                t:set('bumped')
            
            elseif r == 'stuck' then
                t:set('stuck')
            end
        end

        if A then

            -- damage the player
            if r == 'player' then
                -- TODO: be able to specify the attack inside sequence
                w.player:takeHit(self:getAttack():setDir(a), w)
                self.facing = { a[1], a[2] }
                t:set('hit')
            end

        -- elseif contains(step.name, 'break') then
        end

        if I then
            
            t:set('idle')

        end

    end   

    
    
    -- TODO: probably refactor
    self.close = self:isClose(w.player)
    self.close_diagonal = self:isCloseDiagonal(w.player)
    
    
    -- reorient to the player if necessary
    if step.reorient then
        self:orientTo(w.player)
    elseif step.p_close and self.close and step.p_close.reorient then
        self:orientTo(w.player)
    end

    self.emitter:emit('setAction:end', self, a, r, t)
    
    -- save the turn in the history
    t:apply()
    
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
    self.emitter:emit('death')
end

function Enemy:_die()
    transition.to(self.sprite, {
        alpha = 0,
        time = 300,
        transition = easing.linear,
        onComplete = function()
            display.remove(self.sprite)
        end
    })
end


function Enemy:getSeqStep()
    return self.sequence[self.seq_count]
end

function Enemy:updateSeq()
    local step = self:getSeqStep()

    local next_step

    self.emitter:emit('updateSeq:start', self)


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

    self.emitter:emit('updateSeq:end', self)
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

    end
end


-- make other enemies move if they block way
function Enemy:performAction(player_action, w)    
    
    self.emitter:emit('performAction:start', self)

    if self.moved then return end
    
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

    local a, m = contains(step.name, 'attack'), contains(step.name, 'move')

    if self.stuck > 0 and (a or m) then
        self:setAction({}, 'stuck', w)
        return
    end

    -- loop throught all actions
    while(true) do

        i = i + 1
        if i > #acts then break end

        local A = acts[i]

        local ps = self:getPointsFromDirection(A) 
        local rs = {}

        local returnOn = {
            'free',
            'dig'
        }

        for j = 1, #ps do

            local x, y = ps[j][1], ps[j][2]

            -- a wall
            if w.walls[x][y] then

                -- if this enemy can destoy the given wall
                if a and self.dig >= w.walls[x][y].dig_res then 
                    rs[j] = 'dig'
                
                -- if can move, bump
                elseif m then
                    rs[j] = 'block'
                end
                    
            elseif w.entities_grid[x][y] then

                -- check if it's the player
                if w.entities_grid[x][y] == w.player then

                    -- if attacking, attack
                    if a then
                        rs[j] = 'player'
                    
                    -- if moving, bump
                    elseif m then
                        rs[j] = 'enemy'
                    end

                -- an enemy
                elseif a and A[3] == "attack_fellow" then
                    -- attack an enemy? what? why?
                    -- TODO: complete this
                    self.moved = true

                -- take up the place of a dead enemy
                elseif m and w.entities_grid[x][y].dead then
                    rs[j] = 'free'
                    -- return self:setAction(A, 'free', w)


                elseif m and w.entities_grid[x][y].moved == false and 
                    -- prevent calling one another in a loop
                    -- this can happen if an enemy intends to go back
                    not w.entities_grid[x][y].doing_action then
                
                    -- make the enemy move
                    w.entities_grid[x][y]:performAction(player_action, w)
                    -- do the checks for the current iteration again
                    i = i - 1

                    break
                
                -- attack empty space
                elseif a and not m then
                    -- return self:setAction(A, 'free', w) 
                    rs[j] = 'free'
                    
                elseif m then
                    -- bump into the enemy if there's no better move
                    -- responds[i] = 'enemy'
                    rs[j] = 'enemy'
                end


            elseif m then -- free way
                rs[j] = 'free'

            else
                -- do user defined special checks
                if self.doCustomChecks then
                    local ret, rep
                    rs[i], ret, rep = self:doCustomChecks(player_action, w, A)
                    if ret then table.insert(returnOn, rs[j]) end
                    if rep then i = i - 1 break end
                else
                    rs[j] = 'free'
                end
            end
        end

        -- if broke out of the loop, we need to do another iteration
        if #rs == #ps then

            local go_on = true

            -- do custom ones
            if self.doCustomDecision then
                local ret
                responds[i], ret, go_on = self:doCustomDecision(rs, A, w, player_action, returnOn)
                if ret then return self:setAction(A, responds[i], w) end
            end

            if go_on then

                -- if met a return condition ('free', 'dig' or some other user defined)
                for j = 1, #returnOn do
                    if table.all(rs, returnOn[j]) then 
                        return self:setAction(A, returnOn[j], w) 
                    end
                end

                if table.some(rs, 'block') then 
                    responds[i] = 'block'
                elseif table.some(rs, 'enemy') then
                    responds[i] = 'enemy'
                elseif table.some(rs, 'player') then
                    return self:setAction(A, 'player', w)
                else
                    responds[i] = rs[1]
                end

            end

        end


        -- TODO: add projectiles and actions besides these?
    end

    -- if by here it hasn't returned then all actions were meh
    -- in that case just do the first action 
    self:setAction(acts[1], responds[1] or 0, w)
end


function Enemy:bumpLoop()
    if 
        -- if was preparing to attack
        contains(self:getSeqStep().name, 'attack') and 
        -- but has bumped into an enemy
        Turn.was(self.history, 'bumped') and
        -- and hasn't attacked 
        not Turn.was(self.history, 'hit') and
        -- and hasn't bounced
        not Turn.was(self.history, 'bounced')
    then
        -- TODO: Refactor this animation thing
        if self.close then
            self:anim(1000, "angry") 
        else
            self:anim(1000, "ready") 
        end        
        return true
    end
    return false
end

function Enemy:_bouncedDisplacedHit(t, ts, cb)
    self:_displaced(t, ts, cb, self:getSeqStep().anim.attack)
    self:_hit(t, ts)
end

function Enemy:_bouncedDisplaced(t, ts, cb)
    self:_displaced(t, ts, cb, self:getSeqStep().anim.move)
end

function Enemy:_hit(t, ts, cb, a)
    self:_bumped(t, ts, cb, a or self:getSeqStep().anim.attack)
end

function Enemy:_bumped(t, ts, cb, a)
    Entity._bumped(self, t, ts, cb, a or self:getSeqStep().anim.move)
end

function Enemy:_displaced(t, ts, cb, a)
    Entity._displaced(self, t, ts, cb, a or self:getSeqStep().anim.move)
end

function Enemy:_idle(t, ts, cb, a)
    self:anim(1000, a or self:getSeqStep().anim.idle)
    if cb then cb() end
end

return Enemy