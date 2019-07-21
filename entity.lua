
local Turn = require('turn')
local Animated = require('animated')
local Attack = require('attack')

local Entity = Animated:new{
    offset_y_hop = -0.3
}



function Entity:new(...)
    local o = Animated.new(self, unpack(arg))
    o.prev_pos = {}
    o.prev_history = {}
    o.facing = { 0, 0 } -- this is an object, so do not modify it inside some method!
    o.history = {} -- pushing, history and such
    o.emitter = Emitter:new()
    o:on('dead', function() o:deathrattle() end)
    return o
end

-- states
Entity.dead = false


-- boolean states
Entity.sliding = false
Entity.levitating = false

-- these two are a bit special 
Entity.stuck = 0
Entity.stuck_res = 0
Entity.invincible = 0

-- Stats
Entity.dig = 0 -- level of dig (how hard are the walls it can dig)
Entity.dmg = 0 -- damage
Entity.armor = 0 -- damage reduction (down to 1 hp)


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

Entity.size = { 0, 0 }




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


    local s = self.world.env.tiles[self.x][self.y].stucker

    if not s or (s and s ~= self) then    
        self.stuck = 0
    elseif 
        not self.just_stuck and 
        Turn.was(self.history, 'stuck')
    then 
        self.stuck = math.max(self.stuck - 1, 0)
    end

    self.just_stuck = false


    self.invincible = math.max(self.invincible - 1, 0)
end


-- return the actual damage dealt from an attack
function Entity:calculateAttack(a)
    return math.max(
        -- take armor into consideration
        math.max(a.dmg - self.armor, math.min(a.dmg, 1)) -
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
        self.emitter:emit('dead', self)
    end
end


function Entity:getAttack()
    return Attack:new():setDmg(self.dmg or 0)
end


-- bounce off a bounce trap
function Entity:bounce(trap, w)

    local ps = self:getPointsFromDirection(trap.dir)

    local t = Turn:new(self, trap.dir)

    t.trap = trap

    self.emitter:emit('trap:start', self, trap)


    if self == w.player then
        -- face the direction of the bounce
        self.facing = { trap.dir[1], trap.dir[2] }
    end
    
    -- if met an entity
    if areBlocked(ps, w) then

        if  
            -- attack the player
            havePlayer(ps, w) and
            -- if intends to attack
            contains(self:getSeqStep().name, 'attack') and
            -- but hasn't
            not Turn.was(self.history, 'hit')            
        then
            t:set('hit', 'bounced')
            w.player:takeHit(self:getAttack():setDir(trap.dir), w)
            self.emitter:emit('trap:hit', self, trap)

        
        else
            t:set('bumped', 'bounced') 
            self.emitter:emit('trap:bump', self, trap)

        end

    else -- free way
        -- remove itself from the grid
        self:unsetPositions(w)

        -- get displaced
        self.x, self.y = self.x + trap.dir[1], self.y + trap.dir[2]
        t:set('displaced', 'bounced')

        -- insert itself into the grid
        self:resetPositions(w)

        self.emitter:emit('trap:displaced', self, trap)
    end


    t:apply()

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

function Entity:closeMath(p)
    -- just some vector math, need to rewrite with a math library probably
    local ss =  { (self.size[1] + 1) / 2,  (self.size[2] + 1) / 2  }
    local sp =  { (p.size[1] + 1) / 2,     (p.size[2] + 1) / 2     }
    local cs =  { self.x + ss[1],          self.y + ss[2]          }
    local cp =  { p.x    + sp[1],          p.y    + sp[2]          }
    local sss = { ss[1]  + sp[1],          ss[2]  + sp[2]          }
    local dcs = { math.abs(cs[1] - cp[1]), math.abs(cs[2] - cp[2]) }

    return sss, dcs
end


function Entity:isClose(p)
    local sss, dcs = self:closeMath(p)   
    return sss[1] >= dcs[1] and sss[2] >= dcs[2] and not (dcs[1] == dcs[2])
end

function Entity:isCloseDiagonal(p)
    local sss, dcs = self:closeMath(p)   
    return sss[1] >= dcs[1] and sss[2] >= dcs[2] and dcs[1] == dcs[2]
end

function Entity:isCloseAdjacent(p)
    local sss, dcs = self:closeMath(p)   
    return sss[1] >= dcs[1] and sss[2] >= dcs[2]
end


function Entity:push(...)
    local t = self:_thrust(...)
    t:set('pushed')
end


function Entity:thrust(...)
    local t = self:_thrust(...)
    t:set('dashed')
end


function Entity:_thrust(dir, amount, t, w)

    self.emitter:emit('thrust:start', self, dir, amount)


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

            t:set('displaced')
            self.emitter:emit('thrust:displaced', self, dir, i)

        else
            blocked = true
            break
        end
    end

    -- shift the position in grid
    self:resetPositions(w)

    if blocked then
        t:set('bumped') 
        self.emitter:emit('thrust:bumped', self)
    end    
    
    self.emitter:emit('thrust:end', self)    
    
    return t
end


function Entity:go(a, t, w)
    -- delete itself from grid
    self:unsetPositions(w)

    -- update position
    self.x = a[1] + self.x
    self.y = a[2] + self.y

    self.facing = { a[1], a[2] }
    
    t:set('displaced')
    
    -- shift the position in grid
    self:resetPositions(w)
end


function Entity:playAnimation(w, callback)

    self.emitter:emit('animation:start', self, w)

    -- get the animation length, 
    -- scale down if there will be more than one animation (bouncing off traps)
    local l = w:getAnimLength()
    local ts = #self.history == 0 and l or l / (#self.history)

    

    local function _callback()
        if self.dead then
            self:_die()
        else
            self:_idle()
        end
        self.emitter:emit('animation:end', self, w)
        if callback then callback() end
    end

    local function doIteration(i)

        local cb = function() doIteration(i + 1) end

        if self.history[i] then

            self.emitter:emit('animation:step', self, i, w)

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
                    self:_hurt(t, ts, cb)
                end
            
            
            elseif t.hit then

                -- hit while moving
                if t.displaced and t.hit and not t.dashed then
                    self:_displacedHit(t, ts, cb)

                -- hit while dashing having moved forward
                elseif t.dashed and t.displaced then
                    self:_dashedHit(t, ts, cb)

                elseif t.dashed and t.bumped then
                    self:_dashedHitBumped(t, ts, cb)

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

            elseif t.stuck then
                self:_stuck(t, ts, cb)
            
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


function Entity:_bouncedDisplacedHit(t, ts, cb)
    self:_displaced(t, ts, cb)
    self:_hit(t, ts)
end

function Entity:_bouncedDisplaced(...)
    self:_displaced(unpack(arg))
end

function Entity:_bouncedBumped(...)
    self:_hopUp(unpack(arg))
end

function Entity:_hurtPushedBumpedDisplaced(t, ts, cb)
    self:_pushed(t, ts, cb)
    self:_hurt(t, ts)
end

function Entity:_hurtPushedBumped(t, ts, cb)
    self:_bumped(t, ts, cb)
    self:_hurt(t, ts)
end

function Entity:_hurtPushed(t, ts, cb)
    self:_pushed(t, ts, cb)
    self:_hurt(t, ts)
end

function Entity:_hurt(t, ts, cb, a)
    self:anim(ts, a or 'hurt')
    self:playAudio('hurt')
    if cb then cb() end
end

function Entity:_pushed(t, ts, cb, a)
    self:anim(ts, a or 'pushed')
    transition.to(self.sprite, {
        x = t.f_pos.x + self.size[1] / 2,
        y = t.f_pos.y + self.size[2] / 2 + self.offset_y,
        time = ts,
        onComplete = function() if cb then cb() end end
    })
end

function Entity:_hit(...)
    self:_bumped(unpack(arg))
end

function Entity:_bumped(t, ts, cb, a)
    self:anim(ts, a or 'jump')
    transition.to(self.sprite, {
        x = t.i_pos.x + t.a[1] / 2 + self.size[1] / 2,
        y = t.i_pos.y + t.a[2] / 2 + self.size[2] / 2 + self.offset_y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

function Entity:_displaced(t, ts, cb, a)
    self:anim(ts, a or 'jump')
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


function Entity:_displacedHit(t, ts, cb, a)
    self:_displaced(t, ts, cb, a)
    self:_hit(t, ts)
end


function Entity:_idle(t, ts, cb, a)
    self:anim(1000, a or 'idle')
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
        y = t.f_pos.y + self.size[2] / 2 + self.offset_y + self.offset_y_hop,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

function Entity:_dashedHit(...)
    self:_displaced(unpack(arg))
end

function Entity:_dashedHitBumped(...)
    self:_bumped(unpack(arg))
end

function Entity:_stuck(...)
    self:_hopUp(unpack(arg))
end

function Entity:on(...)
    self.emitter:on(unpack(arg))
end

function Entity:isObject()
    return false
end


function Entity:deathrattle()
    -- spawn what's within
    if self.innards then
        self.spawned = self.world:spawn(self.x, self.y, self.innards)
    end
end


-- take damage from an enemy
function Entity:takeHit(att, w)
    
    if self.dead then return end

    self.emitter:emit('hurt:start', self, weapon)


    -- create the turn object
    local t = Turn:new(self, att.dir or false)    

    -- apply pushing etc
    self:applySpecials(att, t, w)
    -- apply debuffs etc
    self:applyDebuffs(att, w)

    -- if pushed or something
    if t._set then
        t:apply()
    end
    
    -- the palyer is invincible, ignore
    if self.invincible > 0 then return end

    -- calculate the attack damage
    local dmg = self:calculateAttack(att) 

    -- ignore 0 damage
    if dmg <= 0 then return end

    -- take damage
    self:loseHP(dmg)        

    self.emitter:emit('hurt:damage', self, weapon)
    
    t:set('hurt')  

    -- insert the turn if it hasn't been inserted already
    if not contains(self.history, t) then
        t:apply()
    end

    return true
end


function Entity:setupSprite()
    self.sprite.x = self.x + self.size[1] / 2
    self.sprite.y = self.y + self.offset_y + self.size[2] / 2
    self.sprite:scale(self.scaleX, self.scaleY)
    self:anim(1000, 'idle')
end



function Entity:die()
    self.emitter:emit('death')
end

function Entity:_die()
    transition.to(self.sprite, {
        alpha = 0,
        time = 300,
        transition = easing.linear,
        onComplete = function()
            display.remove(self.sprite)
        end
    })
end

return Entity