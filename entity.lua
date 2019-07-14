Entity = Animated:new{}



function Entity:new(...)
    local o = Animated.new(self, ...)
    o.prev_pos = {}
    o.prev_history = {}
    o.facing = { 0, 0 } -- this is an object, so do not modify it inside some method!
    o.history = {} -- pushing, history and such
    o.hp = {} -- list of health points (red, blue, yellow, hell knows)
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
function Entity:calculateAttack(a)
    return math.max(
        -- take armor into consideration
        math.max(a.dmg - self.armor, math.min(a.dmg, 0.5)) -
        -- resist damage if not pierced through
        (self.pierce_res < (a.specials.pierce_ing or -999999) and 0 or self.dmg_res), 0)
end


function Entity:applySpecials(a, t, w)
    local s = a.specials
    if s['push_ing'] and s['push_ing'] > self['push_res'] then
        self:push(normComps(a.dir), s['push_amount'], t, w)
    end
end


-- update _ed parameters 
function Entity:applyDebuffs(a)

    local d = a.debuffs

    for i = 1, #DEBUFFS do
        if a[DEBUFFS[i]..'_amount'] and a[DEBUFFS[i]..'_amount'] > 0 and 
            self[DEBUFFS[i]..'_res'] < a[DEBUFFS[i]..'_ing'] 
            then   
                -- reset the debuff count  
                self[DEBUFFS[i]..'_ed'] = a[DEBUFFS[i]..'_amount']
            end
    end
end


function Entity:loseHP(dmg)

    self.health = self.health - dmg

    if (self.health <= 0) then
        self.dead = true 
    end
end


function Entity:getAttack()
    return Attack:new():setDmg(self.dmg or 0)
end


-- bounce off a bounce trap
-- TODO: sizes
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
    elseif w.entities_grid[x][y] and w.entities_grid[x][y] ~= self then

        if  -- attack the player
            w.entities_grid[x][y] == w.player and
            -- if intends to attack
            contains(self:getSeqStep().name, 'attack') and
            -- but hasn't
            not Turn.was(self.history, 'hit')            
        then
            t:setResult('hit', 'bounced')
            w.player:takeHit(self:getAttack():setDir(trap.dir), w)
        
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


-- get positions of right to the left, 
-- right to the right, to the top and to the bottom
function Entity:getNeighborPositions()
    local t = {}
    for i = 0, self.size[1] do
        table.insert(t, { self.x + i, self.y - 1 })
        table.insert(t, { self.x + i, self.y + 1 + self.size[2] })
    end

    for j = 0, self.size[1] do
        table.insert(t, { self.x - 1, self.y + j })
        table.insert(t, { self.x + 1 + self.size[1], self.y + j })
    end
    return t
end


-- get diagonal positions
function Entity:getNeighborPositionsDiagonal()
    return {
        { self.x - 1, self.y - 1 },
        { self.x + self.size[1] + 1, self.y - 1 },
        { self.x - 1, self.y + self.size[2] + 1 },
        { self.x + self.size[1] + 1, self.y + self.size[2] + 1 }
    }
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

        if dir[1] > 0 then
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

        if dir[2] > 0 then
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

                for i = 1, self.size[1] do
                    table.insert(t, { self.x + i, self.y + 1 + self.size[2] })
                end

                for i = 1, self.size[2] do
                    table.insert(t, { self.x + 1 + self.size[1], self.y + i })
                end
            else 
                -- top right
                table.insert(t, { self.x + 1 + self.size[1], self.y - 1 })

                for i = 1, self.size[1] do
                    table.insert(t, { self.x + i, self.y - 1 })
                end
                
                for i = 0, self.size[2] - 1 do
                    table.insert(t, { self.x + 1 + self.size[1], self.y + i })
                end
            end

        else
            
            if dir[2] > 0 then
                -- bottom left
                table.insert(t, { self.x - 1, self.y + 1 + self.size[2] })

                for i = 0, self.size[1] - 1 do
                    table.insert(t, { self.x + i, self.y + 1 + self.size[2] })
                end
                
                for i = 1, self.size[2] do
                    table.insert(t, { self.x - 1, self.y + i })
                end

            else
                -- top left
                table.insert(t, { self.x - 1, self.y - 1 })
                
                for i = 0, self.size[1] - 1 do
                    table.insert(t, { self.x + i, self.y - 1 })
                end
                
                for i = 0, self.size[2] - 1 do
                    table.insert(t, { self.x - 1, self.y + i })
                end

            end

        end
    end
    return t
end


function Entity:isClose(p)
    -- just some vector math, need to rewrite with a math library probably
    local ss =  { (self.size[1] + 1) / 2,  (self.size[2] + 1) / 2  }
    local sp =  { (p.size[1] + 1) / 2,     (p.size[2] + 1) / 2     }
    local cs =  { self.x + ss[1],          self.y + ss[2]          }
    local cp =  { p.x    + sp[1],          p.y    + sp[2]          }
    local sss = { ss[1]  + sp[1],          ss[2]  + sp[2]          }
    local dcs = { math.abs(cs[1] - cp[1]), math.abs(cs[2] - cp[2]) }

    return sss[1] >= dcs[1] and sss[2] >= dcs[2] and not (dcs[1] == dcs[2])
end


function Entity:isCloseDiagonal(p, dir)
    -- TODO: do this in a more elegant way, like the isClose
    -- NOTE: this algorithm is the most inefficient, but this
    -- function is probably never gonna be used anyway 
    local dps = self:getNeighborPositionsDiagonal()
    local ps = p:getPositions()
    for i = 1, #dps do
        for j = 1, #ps do
            if ps[j][1] == dps[i][1] and ps[j][2] == dps[i][2] then
                return true
            end
        end
    end
    return false
end


function Entity:push(...)
    local t = self:_thrust(...)
    t:setResult('pushed')
end


function Entity:thrust(...)
    local t = self:_thrust(...)
    t:setResult('dashed')
end


function Entity:_thrust(dir, amount, t, w)

    local blocked = false

    -- delete itself from grid
    self:unsetPositions(w)

    for i = 1, amount do

        -- get the directions taking into consideration
        -- the sizes of the entity
        local ps = self:getPointsFromDirection(dir)

        if not areBlocked(ps, w) then  
            -- update position
            self.x = dir[1] + self.x
            self.y = dir[2] + self.y

            t:setResult('displaced')            
        else
            blocked = true
            break
        end
    end

    -- shift the position in grid
    self:resetPositions(w)

    if blocked then
        t:setResult('bumped') 
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
    
    t:setResult('displaced')
    
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

            if t.f_facing and t.f_facing[1] ~= 0 then
                self:orient(t.f_facing[1])
            end

            -- if self.enemy then
            -- print('')
            -- print('bounced: ', t.bounced)
            -- print('displaced: ', t.displaced)
            -- print('bumped: ', t.bumped)
            -- print('hit: ', t.hit)
            -- print('hurt: ', t.hurt)
            -- print('dashed: ', t.dashed)
            -- print('pushed: ', t.pushed)
            -- print('idle: ', t.idle)
            -- print('_set: ', t._set)
            -- end

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

            
            elseif t.hurt then

                -- hurt by being pushed into a wall or another enemy
                -- but first tavelled a distance  
                if t.pushed and t.bumped and t.displaced then
                    self:_hurtPushedBumpedDisplaced(t, ts, cb)
                    
                    
                -- hurt by being pushed into a wall or another enemy
                -- maybe also just hurt
                elseif t.pushed and t.bumped then
                    self:_hurtPushedBumped(t, ts, cb)

                
                -- hurt and pushed by the player or another enemy
                elseif t.pushed then
                    self:_hurtPushed(t, ts, cb)
                

                -- hurt but not pushed
                else
                    print('hurt')
                    self:_hurt(t, ts, cb)
                end
            
            
            elseif t.hit then

                if t.dashed then
                    self:_dashedHit(t, ts, cb)
                else
                    self:_hit(t, ts, cb)
                end
            


            -- pushed but not hurt
            elseif t.pushed then
                self:_pushed(t, ts, cb)


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

function Entity:_hurtPushedBumpedDisplaced(...)
    self:_pushed(...)
end

function Entity:_hurtPushedBumped(...)
    self:_bumped(...)
end

function Entity:_hurtPushed(...)
    self:_pushed(...)
end

function Entity:_hurt(t, ts, cb)
    self:anim(ts, 'hurt')
    self:playAudio('hurt')
    if cb then cb() end
end

function Entity:_pushed(t, ts, cb)
    self:anim(ts, 'pushed')
    transition.to(self.sprite, {
        x = t.f_pos.x + self.size[1] / 2,
        y = t.f_pos.y + self.size[2] / 2 + self.offset_y,
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
        x = t.i_pos.x + t.a[1] / 2 + self.size[1] / 2,
        y = t.i_pos.y + t.a[2] / 2 + self.size[2] / 2 + self.offset_y + self.offset_y_jump,
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
        x = (t.f_pos.x + t.i_pos.x) / 2 + self.size[1] / 2,
        y = (t.f_pos.y + t.i_pos.y) / 2 + self.size[2] / 2 + self.offset_y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.linear,
        onComplete = function()
            -- falling down
            transition.to(self.sprite, {
                x = t.f_pos.x + self.size[1] / 2,
                y = t.f_pos.y + self.size[2] / 2 + self.offset_y,
                time = ts / 2,
                transition = easing.linear,
                onComplete = function() 
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
    if cb then cb() end
end

function Entity:_custom()
    if cb then cb() end
end

function Entity:_hopUp(t, ts, cb)
    transition.to(self.sprite, {
        x = t.f_pos.x + self.size[1] / 2,
        y = t.f_pos.y + self.size[2] / 2 + self.offset_y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

function Entity:_dashedHit(...)
    self:_displaced(...)
end

function Entity:preAnimation()
    
end