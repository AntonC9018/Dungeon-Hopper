Wizzrobe = Enemy:new{
    x = 7,
    y = 7,
    offsetY = -0.2,
    sequence = { 
        { name = "idle", a_def = "idle" }, 
        { name = "ready", a_def = "ready", a_close = "angry" }, 
        { name = "move", a_def = "jump", a_dmg = "jump", a_bump = "jump", dirs = { table.unpack(HOR_VER) } } 
    },
    seq_count = 1
}

function Wizzrobe:createSprite()
    self.sprite = display.newSprite(self.group, self.sheet, {
        {
            name = "idle",
            frames = { 1, 3 },
            time = 1000,
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
    
    if self:getSeqStep().dirs then 
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
            if lx then table.insert(actions, { -1, 0 }) end
            if gy then table.insert(actions, { 0, 1 }) end
            if ly then table.insert(actions, { 0, -1 }) end
            if gx then table.insert(actions, { 1, 0 }) end
        elseif self.facing[2] > 0 then -- looking down
            --- ...
            if gy then table.insert(actions, { 0, 1 }) end
            if gx then table.insert(actions, { 1, 0 }) end
            if lx then table.insert(actions, { -1, 0 }) end
            if ly then table.insert(actions, { 0, -1 }) end
        elseif self.facing[2] < 0 then -- looking up
            --- ...
            if gy then table.insert(actions, { 0, 1 }) end
            if gx then table.insert(actions, { 1, 0 }) end
            if lx then table.insert(actions, { -1, 0 }) end
            if ly then table.insert(actions, { 0, -1 }) end
        else -- no direction. Default order!
            -- ...
            if gx then table.insert(actions, { 1, 0 }) end
            if lx then table.insert(actions, { -1, 0 }) end
            if gy then table.insert(actions, { 0, 1 }) end
            if ly then table.insert(actions, { 0, -1 }) end
        end


        self.cur_actions = actions

    else
        self.cur_actions = {}
    end


end

function Wizzrobe:getSeqStep()
    return self.sequence[self.seq_count]
end


-- do nothing
function Wizzrobe:loiter(g)

    if self:getSeqStep().name == "ready" then
        if  math.abs(self.x - g.player.x) == 1 and 
            math.abs(self.y - g.player.y) == 0 then

                self.anim_name = 'a_close'
                self.facing = { g.player.x - self.x, 0 }

        elseif  math.abs(self.y - g.player.y) == 1 and 
                math.abs(self.x - g.player.x) == 0 then

                self.anim_name = 'a_close'
                self.facing = { 0, g.player.y - self.y }
        else
            self.anim_name = 'a_def'
        end

    else
        self.anim_name = 'a_def'
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
        self.anim_name = 'a_bump'
    else 
        self.anim_name = 'a_def'
        self.x = x
        self.y = y
    end
end

function Wizzrobe:bump(i, g)
    self.facing = self.cur_actions[i]

    if (self.facing[1] ~= 0) then
        self:orient(self.facing[1])
    end

    self.anim_name = 'a_bump'

end

function Wizzrobe:play_animation(g)
    
    -- get the animation length, 
    -- scale down if there will be more than one animation (bouncing off traps)
    local l = g:getAnimLength()
    local t = #self.bounces and l or l / #self.bounces

    local function _callback(event)
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

    if self.anim_name == "a_bump" then
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
            onComplete = function () do_bounces(0) end
        })       

    elseif self.anim_name then
        -- play animation
        if self:getSeqStep()[self.anim_name] ~= 'idle' then self.sprite.timeScale = 1000 / t else self.sprite.timeScale = 1 end
        self.sprite:setSequence(self:getSeqStep()[self.anim_name])
        self.sprite:play()

        if self:getSeqStep().name == 'move' then
            -- hop onto the tile
            transition.to(self.sprite, {
                x = self.x,
                y = self.y + self.offsetY,
                transition = easing.inOutQuad,
                time = t,
                onComplete = function () do_bounces(0) end
            })
        else
            do_bounces(0)
        end
    else
        do_bounces(0)
    end
end


function Wizzrobe:reset()
    if self.hit then self.seq_count = 0 end
    Enemy.reset(self)
end