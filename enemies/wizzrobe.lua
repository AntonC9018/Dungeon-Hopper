Wizzrobe = Enemy:new{
    x = 7,
    y = 7,
    offsetY = -0.2,
    sequence = { 
        { anim = "idle" }, 
        { anim = "ready", anim_close = "angry" }, 
        { anim = "jump", anim_dmg = "bump", dirs = HOR_VER } 
    }
}

function Wizzrobe:createSprite()
    self.sprite = display.newSprite(self.group, self.sheet, {
        {
            name = "idle",
            frames = { 1, 3 },
            time = 700,
            loopCount = 0
        },
        {
            name = "ready",
            start = 4,
            count = 1,
            loopCount = 0,
            time = 0
        },
        {
            name = "jump",
            frames = { 1, 3, 2, 3 },
            time = 1000,
            loopCount = 1
        },
        {
            name = "angry",
            start = 5,
            count = 1,
            loopCount = 0,
            time = 0
        }
    })
    self.sprite.x = self.x
    self.sprite.y = self.y + self.offsetY

    self.sprite:scale(self.scaleX, self.scaleY)
    self.sprite:setSequence('idle')
    self.sprite:play()
end

function Wizzrobe:computeAction(player_action, g)
    self.seq_count = self.seq_count >= #self.sequence and 1 or self.seq_count + 1
    
    if self.sequence[self.seq_count].dirs then 
        local gx, gy = g.player.x > self.x, g.player.y > self.y
        local lx, ly = g.player.x < self.x, g.player.y < self.y

        local actions = {}

        -- So this is basically if-you-look-to-the-left,- 
        -- you-would-prefer-to-go-to-the-left action

        if self.facing[1] > 0 then -- looking right
            -- prioritize going to the right
            if gx then table.insert(actions, { 1, 0 }) end
            if gy then table.insert(actions, { 0, 1 }) end
            if ly then table.insert(actions, { 0, -1 }) end
            if lx then table.insert(actions, { -1, 0 }) end
        elseif self.facing[1] < 0 then -- looking left
            -- prioritize going to the left
            if lx then table.insert(actions, { 1, 0 }) end
            if gy then table.insert(actions, { 0, 1 }) end
            if ly then table.insert(actions, { 0, -1 }) end
            if gx then table.insert(actions, { -1, 0 }) end
        elseif self.facing[2] > 0 then -- looking down
            --- ...
            if gy then table.insert(actions, { 0, 1 }) end
            if gx then table.insert(actions, { -1, 0 }) end
            if lx then table.insert(actions, { 1, 0 }) end
            if ly then table.insert(actions, { 0, -1 }) end
        elseif self.facing[2] < 0 then -- looking up
            --- ...
            if gy then table.insert(actions, { 0, 1 }) end
            if gx then table.insert(actions, { -1, 0 }) end
            if lx then table.insert(actions, { 1, 0 }) end
            if ly then table.insert(actions, { 0, -1 }) end
        else -- no direction. Default order!
            -- ...
            if gx then table.insert(actions, { -1, 0 }) end
            if lx then table.insert(actions, { 1, 0 }) end
            if gy then table.insert(actions, { 0, 1 }) end
            if ly then table.insert(actions, { 0, -1 }) end
        end


        self.cur_actions = actions

    else
        self.cur_actions = {}
    end


end


-- do nothing
function Wizzrobe:loiter(g)

    if self.sequence[self.seq_count].name == "ready" then
        if  math.abs(self.x - g.player.x) == 1 and 
            math.abs(self.y - g.player.y) == 0 then

                self.anim_name = self.sequence[self.seq_count]['anim_close']
                self.facing = { g.player.x - self.x, 0 }

        elseif  math.abs(self.y - g.player.y) == 1 and 
                math.abs(self.x - g.player.x) == 0 then

                self.anim_name = self.sequence[self.seq_count]['anim_close']
                self.facing = { 0, g.player.y - self.y }
        else
            self.anim_name = self.sequence[self.seq_count]['anim']
        end

    else
        self.anim_name = self.sequence[self.seq_count]['anim']
    end

    if (self.facing[1] ~= 0) then
        self:orient(self.facing[1])
    end

end

-- move / attack
function Wizzrobe:move(i, g)

    self.facing = self.cur_actions[i]

    if (self.facing[1] ~= 0) then
        self:orient(self.facing[1])
    end

    local x, y = self.x + self.facing[1], self.y + self.facing[2]

    if g.player.x == x and g.player.y == y then
        g.player:damage(self)
        self.anim_name = self.sequence[self.seq_count]['dmg']
    else 
        self.anim_name = self.sequence[self.seq_count]['anim']
        self.x = x
        self.y = y
    end
end

function Wizzrobe:bump(i, g)
    self.facing = self.cur_actions[i]

    if (self.facing[1] ~= 0) then
        self:orient(self.facing[1])
    end

    self.anim_name = 'bump'

end

function Wizzrobe:play_animation(g)
    
    -- get the animation length, 
    -- scale down if there will be more than one animation (bouncing off traps)
    local l = g:getAnimLength()
    local t = #self.bounce and t or t / #self.bounce

    local function _callback(event)
        self.sprite.timeScale = 1
        self.sprite:setSequence('idle')
        self.sprite:play()
        if callback then callback(event) end
    end

    -- recursive bouncing
    local function do_bounces(i)
        i = (i or 0) + 1        
        
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
                    y = self.y + 0.4,
                    transition = easing.continuousLoop,
                    time = t / 2
                })
                transition.to(self.sprite, {
                    x = self.x,
                    transition = easing.inOutQuad,
                    time = t,
                    onComplete = cb
                })            
            else
                transition.to(self.follow_group, {
                    x = self.x,
                    y = self.y,
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
        -- play animation
        self.sprite.timeScale = 1000 / t
        self.sprite:setSequence('jump')
        self.sprite:play()
        -- hop to and back
        transition.to(self.sprite, {
            x = self.x - self.facing[1] / 2,
            y = self.y - self.facing[2] / 2 + self.offsetY,
            transition = easing.continuousLoop,
            time = t / 2,
            onComplete = do_bounces
        })
        self.seq_count = self.seq_count - 1

    elseif self.action_name == "jump" then
        -- play animation
        self.sprite.timeScale = 1000 / t
        self.sprite:setSequence('jump')
        self.sprite:play()
        -- hop onto the tile
        transition.to(self.sprite, {
            x = self.x,
            y = self.y,
            transition = easing.inOutQuad,
            time = t,
            onComplete = do_bounces
        })
    elseif self.action_name == "ready" then
        -- play animation
        self.sprite:setSequence('ready')
        self.sprite:play()
        do_bounces()
    elseif self.action_name == "angry" then
        -- play animation
        self.sprite:setSequence('angry')
        self.sprite:play()
        do_bounces()
    else
        do_bounces()
    end
end