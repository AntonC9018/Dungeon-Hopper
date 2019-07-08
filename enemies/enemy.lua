
-- HOR_VER = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
-- DIAGONAL = { { 1, 1 }, { -1, -1 }, { -1, 1 }, { 1, -1 } }

-- movement types
BASIC = 1 -- basic right left up down (orthogonal) movement towards player
DIAGONAL = 2 -- diagonal movement towards player
STRAIGHT = 3 -- go in a straight line
ADJACENT = 4 -- go vertically, horizontally or diagonally towards player


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
-- abstract
function Enemy:getAction(w) end
-- abstract
function Enemy:move(action, w) end


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
    elseif self:getSeqStep().mov == BASIC then
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

    
    elseif self:getSeqStep().mov == DIAGONAL then

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


    elseif self:getSeqStep().mov == ADJACENT then

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


    -- move continuously in a straight line
    elseif self:getSeqStep().mov == STRAIGHT then
        table.insert(actions, { self.facing[1], self.facing[2] })
    end

    self.cur_actions = actions
end


function Enemy:takeDamage(dir, from)
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
    -- specific for an Enemy
    self.seq_count = (self.seq_count >= #self.sequence and 1) or (self.seq_count + 1)

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

function Enemy:face(p, dir)
    -- player is right to the right or to the left
    if math.abs(p.x - self.x) == 1 and math.abs(p.y - self.y) == 0 then
        -- self.facing = { p.x - self.x, 0 }
        return true
    -- player is right to the top or to the bottom
    elseif  math.abs(p.x - self.x) == 0 and math.abs(p.y - self.y) == 1 then
        -- self.facing = { p.y - self.y, 0 }
        return true
    end

    return false
end

function Enemy:getSeqStep()
    return self.sequence[self.seq_count]
end

function Enemy:updateSeq()
    self.seq_count = self.seq_count + 1
end

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