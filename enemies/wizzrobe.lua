Wizzrobe = Enemy:new{
    x = 7,
    y = 7,
    offsetY = -0.2,
    sequence = { 
        { name = "idle" }, 
        { name = "ready" }, 
        { name = "move/attack", dirs = { table.unpack(HOR_VER) } } 
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


function Wizzrobe:setAction(a, r, g)

    -- "Current action"
    self.cur_a = a
    -- "[ (to the) Current (<-->) response ] (action)"
    self.cur_r = r


    if self:getSeqStep().name == 'move/attack' then
        -- change orientation
        if a[1] ~= 0 then
            self:orient(a[1])
        end

        -- Free way, just move
        if r == FREE then
            self.x = a[1] + self.x
            self.y = a[2] + self.y
            self.facing = { a[1], a[2] }
        -- damage the player
        elseif r == PLAYER then
            g.player:damage(self)
            -- TODO: pushing a player back if the enemy must do so
        end
        -- TODO: cases with walls, where the enemy might 
        -- destroy a wall or damage a wall or whatever 

    elseif self:getSeqStep().name == 'ready' then
        -- change orientation
        self:orientTo(g.player)
    end
end

function Wizzrobe:anim(ts, name)
    self.sprite.timeScale = ts
    self.sprite:setSequence(name)
    self.sprite:play()
end

function Wizzrobe:trans(o)
    transition.to(self.sprite, o)
end

function Wizzrobe:orientTo(player)
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


function Wizzrobe:play_animation(g)
    -- get the step in sequence
    local step = self:getSeqStep()
    -- get the time of animations and transitions
    local l = g:getAnimLength()
    local t = #self.bounces and l or l / #self.bounces


    -- no bounces
    -- NOTE: "Bounces" in this context are 
    -- any pushing action (effects of traps, other enemies, bombs so on)
    if #self.bounces == 0 then

        print('no bounces')

        -- the enemy does nothing
        if step.name == "idle" then
            self:anim(1, "idle")

        -- the enemy is preparing to attack
        elseif step.name == "ready" then
            print("ready")
            -- turn to player if they are close
            local turned = self:face(g.player)
            if turned then
                -- play anger animation
                self:anim(1, 'angry')
            else
                -- play ready animation
                self:anim(1, 'ready')
            end                
        end
    end -- if not #self.bounces
    
    -- there are bounces
    -- now THIS is a bit more complicated
    -- I just add the function that iterates 
    -- through bounces as a callback to transitions
    
    -- LO AND BEHOLD
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
                -- TODO: add an emitter that other objects could hook up to
                -- and broadcast events such as this 
                and function() end 
                -- do the next animation
                or function() do_bounces(i) end 

            -- TODO: add types of bouncing (i.e. not just traps 
            -- but also pushing, which would use other animations)

            -- play animation
            self:anim(1000 / t, 'jump')

            if not self.bounces[i][2] then
                -- if hopping to the right or to the left, jump up a little
                self:trans({
                    -- TODO: this 0.4 is too arbitrary, make that a property
                    y = self.y + 0.4 + self.offsetY,
                    transition = easing.continuousLoop,
                    time = t / 2
                })
                self:trans({
                    x = self.x,
                    transition = easing.inOutQuad,
                    time = t,
                    onComplete = cb
                })            
            else
                self:trans({
                    x = self.x,
                    y = self.y + self.offsetY,
                    transition = easing.inOutQuad,
                    time = t,
                    onComplete = cb
                })
            end
        else
            -- TODO: add an emitter as discussed earlier
            -- _callback({ phase = "end" })
        end
    end


    -- the enemy intends to move / attack
    if step.name == "move/attack" then
        -- check what is the response

        -- it hit the player this beat
        if self.cur_r == PLAYER then
            -- play hit animation
            self:anim(1000 / t, 'jump')
            -- jump to and back
            self:trans({ 
                x = self.x + self.cur_a[1] / 2, 
                y = self.y + self.cur_a[2] / 2 + self.offsetY,
                time = t / 2,
                transition = easing.continuousLoop,
                onComplete = function() do_bounces(0) end
            })
        
        -- The way is lit, the path is clear!
        elseif self.cur_r == FREE then
            -- play the jump animation
            self:anim(1000 / t, 'jump')
            -- jump to the tile
            self:trans({
                x = self.x,
                y = self.y + self.offsetY,
                time = t,
                transition = easing.inOutQuad,
                onComplete = function() do_bounces(0) end
            })
        
        -- bump into the block or the enemy
        elseif self.cur_r == BLOCK or self.cur_r == ENEMY then
            -- play hit animation
            self:anim(1000 / t, 'jump')
            -- jump to and back
            self:trans({ 
                x = self.x + self.cur_a[1] / 2, 
                y = self.y + self.cur_a[2] / 2 + self.offsetY,
                time = t / 2,
                transition = easing.continuousLoop,
                onComplete = function() do_bounces(0) end
            })
        end
        -- TODO: think about being pushed while getting ready or idling
    end

end


function Wizzrobe:reset()
    -- TODO: call this something like 'weak'
    if self.hit then self.seq_count = 0 end
    Enemy.reset(self)
end