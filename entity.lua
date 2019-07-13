Entity = Animated:new{}

local DEBUFFS = {'stun', 'confuse', 'tiny', 'poison', 'fire', 'freeze'}

local SPECIAL = {'push', 'pierce'}


function Entity:new(...)
    local o = Animated.new(self, ...)
    o.history = {}
    o.prev_pos = {}
    return o
end

-- states
-- game logic states
Entity.displaced = false -- TODO: change to number of tile?
Entity.bumped = false
Entity.hit = false -- TODO: change to number of guys hit?
Entity.hurt = false -- TODO: change to damage taken?
Entity.dead = false
Entity.dug = false -- dug a tile this loop

-- boolean states
Entity.sliding = false
Entity.levitating = false

-- these two are a bit special 
Entity.stuck = 0
Entity.invincible = 0

-- Stats
Entity.hp = {} -- list of health points (red, blue, yellow, hell knows)
Entity.dig = 0 -- level of dig (how hard are the walls it can dig)
Entity.dmg = 0 -- damage
Entity.armor = 0 -- damage reduction (down to 0.5 hp)


-- set up default values for debuff properties
for i = 1, #DEBUFFS do
    -- _ed stats, decremented each loop
    Entity[DEBUFFS[i]..'_ed'] = 0
    -- _ing stats
    Entity[DEBUFFS[i]..'_ing'] = 0
    -- _res stats
    Entity[DEBUFFS[i]..'_res'] = 0
    -- _amount stats. Amount of an effect in an attack
    -- For example, the amount of seconds the attacked is gonna burn
    Entity[DEBUFFS[i]..'_amount'] = 0
end

-- Do the same for special effects
for i = 1, #SPECIAL do
    Entity[SPECIAL[i]..'_ing'] = 0
    Entity[SPECIAL[i]..'_res'] = 0
    Entity[SPECIAL[i]..'_amount'] = 0
end

-- numerical stats
Entity.dmg_res = 0 -- minimal amount of damage to punch through

-- these are a bit special
-- normal attacks cannot apply these
Entity.explode_res = 0
Entity.stuck_res = 0
Entity.slide_res = 0

-- vector values
-- direction the thing is pointing
-- Entity.facing = { 0, 0 } -- this is an object, so do not modify it inside some method!
-- Entity.last_a = {} -- last action
-- Entity.cur_a = {} -- current action
-- Entity.history = {} -- pushing, history and such


function Entity:reset()
    self.prev_pos = { x = self.x, y = self.y }
    self.prev_history = self.history
    self.history = {}
end


-- Decrement all debuffs
function Entity:tickAll()
    
    for i = 1, #DEBUFFS do
        self[DEBUFFS[i]..'_ed'] = math.max(self[DEBUFFS[i]..'_ed'] - 1, 0)
    end

    self.stuck = math.max(self.stuck - 1, 0)
    self.invincible = math.max(self.invincible - 1, 0)
end


-- return the actual damage dealt from an attack
function Entity:calculateAttack(from)
    return math.max(
        -- take armor into consideration
        math.max(from.dmg - self.armor, 0.5) -
        -- resist damage if not pierced through
        (self.pierce_res < from.pierce_ing and 0 or self.dmg_res), 0)
end


-- update _ed parameters 
function Entity:applyDebuffs(from)

    for i = 1, #DEBUFFS do
        if  from[DEBUFFS[i]..'_amount'] > 0 and 
            self[DEBUFFS[i]..'_res'] < from[DEBUFFS[i]..'_ing'] 
            then   
                -- reset the debuff count  
                self[DEBUFFS[i]..'_ed'] = from[DEBUFFS[i]..'_amount']
            end
    end
end


function Entity:loseHP(dmg)

    self.health = self.health - dmg

    if (self.health <= 0) then
        self.dead = true 
    end
end


-- bounce off a bounce trap
function Entity:bounce(trap, w)

    local x, y = self.x + trap.dir[1], self.y + trap.dir[2]

    local t = Turn:new(self, trap.dir)

    t.trap = trap

    if self == w.player then
        -- face the direction of the bounce
        self.facing = { trap.dir[1], trap.dir[2] }
    end

    -- stay at place if met a wall
    if w.walls[x][y] then        
        t:setResult('bumped', 'bounced')
    
    -- if met an entity
    elseif w.entities_grid[x][y] then

        if  -- attack the player
            w.entities_grid[x][y] == w.player and
            -- if intends to attack
            contains(self:getSeqStep().name, 'attack') and
            -- but hasn't
            not Turn.was(self.history, 'hit')            
        then
            t:setResult('hit', 'bounced')
            w.player:takeHit(self)
        
        else
            t:setResult('bumped', 'bounced') 
        end

    else -- free way
        -- remove itself from the grid
        self:unsetPositions(w)

        -- get displaced
        self.x, self.y = x, y
        t:setResult('displaced', 'bounced')

        -- insert itself into the grid
        self:resetPositions(w)
    end


    table.insert(self.history, t)

    return t
end


-- delete the positions of itself from the grid
function Entity:unsetPositions(w)
    local ps = self:getPositions()
    for i = 1, #ps do
        w.entities_grid[ps[i][1]][ps[i][2]] = false
    end
end


-- set the positions of itself back in the grid
function Entity:resetPositions(w)
    local ps = self:getPositions()
    for i = 1, #ps do
        w.entities_grid[ps[i][1]][ps[i][2]] = self
    end
end


-- get positions that the creature occupies
function Entity:getPositions()
    local t = {}
    for i = 0, self.size[1] do
        for j = 0, self.size[2] do
            table.insert(t, { self.x + i, self.y + j })
        end
    end
    return t
end


-- get all adjacent positions
function Entity:getAdjacentPositions()
    local t = {}

    for i = -1, self.size[1] + 1 do
        table.insert(t, { self.x + i, self.y - 1 })
        table.insert(t, { self.x + i, self.y + 1 + self.size[2] })
    end

    for j = 0, self.size[1] do
        table.insert(t, { self.x - 1, self.y + j })
        table.insert(t, { self.x + 1 + self.size[1], self.y + j })
    end

    return t
end

-- given a direction, i.e. { 1, 0 }
-- return all positions associated with that direction
-- taking into considerations the sizes of the enemy 
function Entity:getPointsFromDirection(dir)
    local t = {} 

    if dir[1] ~= 0 and dir[2] == 0 then

        if dir[1] > 1 then
            -- right
            for j = 0, self.size[2] do
                table.insert(t, { self.x + self.size[1] + 1, self.y + j })
            end
        else
            -- left
            for j = 0, self.size[2] do
                table.insert(t, { self.x - 1, self.y + j })
            end
        end

    elseif dir[2] ~= 0 and dir[1] == 0 then

        if dir[2] > 1 then
            -- bottom
            for i = 0, self.size[1] do
                table.insert(t, { self.x + i, self.y + self.size[2] + 1 })
            end
        else
            -- top
            for i = 0, self.size[1] do
                table.insert(t, { self.x + i, self.y - 1 })
            end
        end

    else -- got diagnal direction

        if dir[1] > 0 then

            if dir[2] > 0 then
                -- bottom right
                table.insert(t, { self.x + 1 + self.size[1], self.y + 1 + self.size[2] })
            else 
                -- top right
                table.insert(t, { self.x + 1 + self.size[1], self.y - 1 })
            end

        else
            
            if dir[2] > 0 then
                -- bottom left
                table.insert(t, { self.x - 1, self.y + 1 + self.size[2] })
            else
                -- top left
                table.insert(t, { self.x - 1, self.y - 1 })
            end

        end
    end
    return t
end


function Entity:go(a, t, w)
    -- delete itself from grid
    self:unsetPositions(w)

    -- update position
    self.x = a[1] + self.x
    self.y = a[2] + self.y

    self.facing = { a[1], a[2] }
    
    t:setResult('displaced', { x = self.x, y = self.y })
    
    -- shift the position in grid
    self:resetPositions(w)
end


function Entity:playAnimation(w, callback)

    self:preAnimation(w)

    -- get the animation length, 
    -- scale down if there will be more than one animation (bouncing off traps)
    local l = w:getAnimLength()
    local ts = #self.history == 0 and l or l / (#self.history)


    local function _callback()
        self:_idle()
        if callback then callback() end
    end

    local function doIteration(i)

        local cb = function() doIteration(i + 1) end

        if self.history[i] then

            local t = self.history[i]

            print(ins(t.f_facing))

            if t.f_facing and t.f_facing[1] ~= 0 then
                self:orient(t.f_facing[1])
            end

            -- a bounce trap action
            if t.bounced then

                -- push the button
                t.trap:bePushed(ts)


                -- hit the player by being displaced by the trap
                if t.hit then
                    self:_bouncedDisplacedHit(t, ts, cb)


                -- just displaced by the trap
                elseif t.displaced then
                    self:_bouncedDisplaced(t, ts, cb)

                
                -- bumped into a wall by bouncing off a trap
                elseif t.bumped then
                    self:_bouncedBumped(t, ts, cb)


                -- user defined
                else
                    self:_bounced(t, ts, cb)
                end


            -- hurt by being pushed into a wall or another enemy
            -- maybe aditionally just hurt
            elseif t.hurt and t.pushed and t.bumped then
                self:_hurtPushedBumped(t, ts, cb)

            
            -- hurt and pushed by the player or another enemy
            elseif t.hurt and t.pushed then
                self:_hurtPushed(t, ts, cb)
            

            -- hurt but not pushed
            elseif t.hurt then
                self:_hurt(t, ts, cb)


            -- pushed but not hurt
            elseif t.pushed then
                self:_pushed(t, ts, cb)


            -- attacked an enemy / the player
            elseif t.hit then
                self:_hit(t, ts, cb)


            -- bumping into an enemy / player / wall
            elseif t.bumped then
                self:_bumped(t, ts, cb)

            
            -- jumping / moving / walking
            elseif t.displaced then
                self:_displaced(t, ts, cb)

            
            elseif t.idle then
                self:_idle(t, ts, cb)
            
            elseif t.dug then
                self:_dug(t, ts, cb)
            
            else -- custom actions
                self:_custom(t, ts, cb)
            end


        else
            _callback()
        end
    end

    -- start the animations
    doIteration(1)
end


function Entity:_bouncedDisplacedHit(...)
    self:_hit(...)
end

function Entity:_bouncedDisplaced(...)
    self:_displaced(...)
end

function Entity:_bouncedBumped(...)
    self:_hopUp(...)
end

function Entity:_hurtPushedBumped(...)
    self:_pushed(...)
end

function Entity:_hurtPushed(...)
    self:_hurt(...)
end

function Entity:_hurt(t, ts, cb)
    self:anim(ts, 'hurt')
    self:playAudio('hurt')
    if cb then cb() end
end

function Entity:_pushed(t, ts, cb)
    self:anim(ts, 'pushed')
    transition.to(self.sprite, {
        x = t.f_pos.x,
        y = t.f_pos.y + self.offset_y,
        time = ts,
        onComplete = function() if cb then cb() end end
    })
end

function Entity:_hit(...)
    self:_bumped(...)
end

function Entity:_bumped(t, ts, cb)
    self:anim(ts, 'jump')
    transition.to(self.sprite, {
        x = t.i_pos.x + t.a[1] / 2,
        y = t.i_pos.y + t.a[2] / 2 + self.offset_y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

function Entity:_displaced(t, ts, cb)
    self:anim(ts, 'jump')
    -- this animation consists of two steps
    -- first is the first half - jumping up
    transition.to(self.sprite, {
        x = (t.f_pos.x + t.i_pos.x) / 2,
        y = (t.f_pos.y + t.i_pos.y) / 2 + self.offset_y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.linear,
        onComplete = function()
            -- falling down
            transition.to(self.sprite, {
                x = t.f_pos.x,
                y = t.f_pos.y + self.offset_y,
                time = ts / 2,
                transition = easing.linear,
                onComplete = function() 
                    print('cb')
                    if cb then cb() end 
                end
            })
        end
    })
end

function Entity:_idle(t, ts, cb)
    self:anim(1000, 'idle')
    if cb then cb() end
end

function Entity:_dug()
end

function Entity:_custom()
end

function Entity:_hopUp(t, ts, cb)
    transition.to(self.sprite, {
        x = t.f_pos.x,
        y = t.f_pos.y + self.offset_y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

function Entity:preAnimation()
    
end