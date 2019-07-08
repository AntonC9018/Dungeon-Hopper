Wizzrobe = Enemy:new{
    offset_y = -0.3,
    offset_y_jump = -0.2,
    sequence = { 
        { name = "idle" }, 
        { name = "ready" }, 
        { name = "move/attack", mov = ADJACENT } 
    },
    seq_count = 1,
    bounces = {}
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
    self.sprite.y = self.y + self.offset_y

    self.sprite:scale(self.scaleX, self.scaleY)
    self:anim(1, 'idle')
end


function Wizzrobe:setAction(a, r, w)

    -- "Current action"
    self.cur_a = a
    -- "[ (to the) Current (<-->) response ] (action)"
    self.cur_r = r


    if self:getSeqStep().name == 'move/attack' then

        -- Free way, just move
        if r == FREE then
            self.x = a[1] + self.x
            self.y = a[2] + self.y
            self.facing = { a[1], a[2] }
            self.displaced = true
        -- damage the player
        elseif r == PLAYER then
            w.player:takeDamage(self)
            self.facing = { a[1], a[2] }
            self.hit = true
            -- TODO: pushing a player back if the enemy must do so
        end
        -- TODO: cases with walls, where the enemy might 
        -- destroy a wall or damage a wall or whatever 

    elseif self:getSeqStep().name == 'ready' then
        -- change orientation
        -- self:orientTo(w.player)
    end
end


function Wizzrobe:play_animation(w)
    -- get the step in sequence
    local step = self:getSeqStep()

    if self.dead then
        self:die()
        return 
    end


    -- get the time of animations and transitions
    local l = w:getAnimLength()
    local t = #self.bounces and l or l / #self.bounces

    -- change orientation
    if self.facing[1] ~= 0 then
        self:orient(self.facing[1])
    end

    -- no bounces
    -- NOTE: "Bounces" in this context are 
    -- any pushing action (effects of traps, other enemies, bombs so on)
    if #self.bounces == 0 then

        -- the enemy does nothing
        if step.name == "idle" then
            self:anim(1, "idle")

        -- the enemy is preparing to attack
        elseif step.name == "ready" then

            -- turn to player if they are close
            local turned = self:face(w.player)
            if turned then
                -- play anger animation
                self:anim(1, 'angry')
            else
                -- play ready animation
                self:anim(1, 'ready')
            end                
        end
    end -- if not #self.bounces
    
    -- there are bounces (or not)
    -- now THIS is a bit more complicated
    -- I just add the function that iterates 
    -- through bounces as a callback to transitions
    
    -- LO AND BEHOLD
    -- recursive bouncing
    -- TODO: not actually move inside this
    -- TODO: REFACTOR the hell out of this one
    -- TODO: Put outside, like in Entity class
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
                    y = self.y + self.offset_y_jump + self.offset_y,
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
                    y = self.y + self.offset_y,
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
                y = self.y + self.cur_a[2] / 2 + self.offset_y,
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
                y = self.y + self.offset_y,
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
                y = self.y + self.cur_a[2] / 2 + self.offset_y,
                time = t / 2,
                transition = easing.continuousLoop,
                onComplete = function() do_bounces(0) end
            })
        end
        -- TODO: think about being pushed while getting ready or idling
    end
end

function Wizzrobe:takeDamage(dir, player)
    -- TODO: call this something like 'weak'
    self.seq_count = 1

    Enemy.takeDamage(self, dir, player)
end


function Wizzrobe:reset(w)
    -- if tried to move but didn't, move again
    if self:getSeqStep().name == 'move/attack' and not self.displaced and not self.hit then
        self.seq_count = 3 - 1

        -- turn to player if they are close
        local turned = self:face(w.player)
        if turned then
            -- play anger animation
            self:anim(1, 'angry')
        else
            -- play ready animation
            self:anim(1, 'ready')
        end  
    end
    
    Enemy.reset(self)
    Enemy.tickAll(self)
end