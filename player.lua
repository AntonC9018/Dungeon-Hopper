local Entity = require('entity')
local HP = require('hp')
local Turn = require('turn')
local Attack = require('attack')


local Player = Entity:new{
    offset_y = -0.4,
    offset_y_jump = -0.2,
    invincible = 0,
    invincible_max = 2,
    pierce_ing = 1,
    size = { 0, 0 },
    priority = 1    
}

Player:loadAssets(assets.Player)

function Player:new(...)
    local o = Entity.new(self, unpack(arg))
    o.hp = HP:new():set('red', 6)
    o.to_drop = {}
    o.items = {}
    o:createSprite()
    return o
end

function Player:createSprite()
    self.sprite = display.newSprite(self.world.group, self.sheet, {
        {
            name = "idle",
            start = 1,
            count = 4,
            time = 600,
            loopCount = 0
        },
        {
            name = "jump",
            frames = { 1, 6, 9, 9, 7 },
            time = 1000,
            loopCount = 1
        }
    })
    -- place the sprite in the middle of the screen
    self.sprite.x = self.x
    self.sprite.y = self.y + self.offset_y

    self.sprite:scale(self.scaleX, self.scaleY)
    
    self.sprite:setSequence('idle')
    self.sprite:play()
end

-- a stands for action
-- w stands for world
function Player:act(a, w)     

    local t = Turn:new(self, a)

    self.moved = true

    if self.stuck > 0 then
        return Turn:new(self):set('stuck'):apply()
    end

    if a[3] then
        self.emitter:emit('act:special', self, dir)

        -- special a
        -- self:special(a, w)
    else 
        self.emitter:emit('act:normal', self, dir)
        
        if a[1] == nil then
            self:dropBeat() 
        end
        -- look to the proper direction
        self.facing = { a[1], a[2] }
        
        
        -- attempt to attack
        local enemy = self:attack(a, t, w)

        -- if attacking set the turn, refresh
        if t._set then
            t:apply()
            t = Turn:new(self, a)
        end

        local wall 

        -- if did not attack or can dig after attacking
        if not enemy or (self.weapon and self.weapon.dig_and_gun) then
            -- attempt to dig
            wall = self:dig(a, t, w)
        end

        -- if digging set the turn, refresh
        if t._set then
            t:apply()
            t = Turn:new(self, a)
        end

        if 
        
        -- if did not attack or can move after attacking 
        (not enemy or (self.weapon and self.weapon.run_and_gun))

        -- and did not dig
        and not dug
        
        then
            self:move(a, t, w)
        end

        -- if moved, add the turn
        if t._set then
            t:apply()
        end
    end
end


function Player:dropBeat()
end


-- attempt to attack
function Player:attack(dir, t, w)

    if self.weapon then
        return self.weapon:attemptAttack(dir, t, w, self)
    end

    -- if no weapon
    local x, y = self.x + dir[1], self.y + dir[2]
    
    if w.entities_grid[x][y] and w.entities_grid[x][y] ~= self then         
        t:set('bumped')
        self.emitter:emit('attack:bump', self, dir)
        return w.entities_grid[x][y]
    end
end

-- return the attack object
-- modified by items that are on
function Player:getAttack()
    local a = Attack:new()
    a:setDmg(self.dmg)
    a:copyAll(self)
    for i = 1, #self.items do
        self.items[i]:modifyAttack(a)       
    end    
    return a
end

-- attempt to dig
function Player:dig(dir, t, w)

    local x, y = self.x + dir[1], self.y + dir[2]
    
    -- TODO: reconsider 
    if w.walls[x][y] then
        local wall
        wall, w.walls[x][y] = w.walls[x][y], false
        t:set('dug')
        self.emitter:emit('dig:dug', self, dir)
        return wall
    end

    self.emitter:emit('dig:fail', self, dir)


    return false

end

-- attempt to move
function Player:move(dir, t, w)       
    -- there is no enemies in the way
    if     
        w.entities_grid[self.x + dir[1]][self.y + dir[2]] or 
        w.walls[self.x + dir[1]][self.y + dir[2]]     
    then
        t:set('bumped')
        self.emitter:emit('move:bump', self, dir)
    else
        -- go forward
        self:go(dir, t, w)
        self.emitter:emit('move:went', self, dir)
    end
end

-- take damage from an enemy
function Player:takeHit(att, w)

    self.emitter:emit('hurt:start', self, weapon)


    -- create the turn object
    local t = Turn:new(self, att.dir or false)    

    -- apply pushing etc
    self:applySpecials(att, t, w)

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
    
    
    -- taking damage drops beat
    self:dropBeat() 

    -- take damage
    self:loseHP(dmg)    
    -- apply debuffs etc
    self:applyDebuffs(att, w)

    self.emitter:emit('hurt:damage', self, weapon)
    
    t:set('hurt')  

    -- insert the turn if it hasn't been inserted already
    if not contains(self.history, t) then
        t:apply()
    end


    -- start flickering
    self.flicker = transition.to(self.sprite, {
        alpha = 0,
        transition = easing.continuousLoop,
        time = 200,
        iterations = 0
    })
    -- reset fliker count
    self.invincible = self.invincible_max

    return true
end


-- equipping a weapon 
-- TODO: or an item
function Player:equip(weapon)
    self.emitter:emit('equip:start', self, weapon)

    table.insert(self.to_drop, self.weapon)
    self.weapon = weapon

    -- TODO: refactor
    self.dmg = weapon.dmg

    -- play equip sound


    self.emitter:emit('equip:end', self, weapon)
end


function Player:syncCamera(...)
    self.camera:sync(self, ...)
end


-- for now
function Player:_hurt(t, ts, cb)
    self:playAudio('hurt')
    if cb then cb() end
end


function Player:_hit(t, ts, cb)
    self.weapon:play_animation(ts)
    self.weapon:playAudio()
    if cb then cb() end
end


function Player:_dashedHit(t, ts, cb)
    self:_hit(t, ts)
    self:_displaced(t, ts, cb)
end

function Player:_dug(t, ts, cb)
    self:playAudio('dig')
    if cb then cb() end
end


function Player:reset()
    self.emitter:emit('reset:start', self)

    self.attacked_enemy = false
    Entity.tickAll(self)

    -- stop flickering
    if self.invincible <= 0 and self.flicker then
        -- stop flickering
        transition.cancel(self.flicker)
        -- restore alpha
        transition.to(self.sprite, {
            alpha = 1,
            time = 100
        })
        self.sprite.alpha = 1
    end

    Entity.reset(self)

    self.emitter:emit('reset:end', self)
end

-- TODO: improve this
function Player:loseHP(dmg)
    local status, residue = self.hp:take(dmg)
    print(self.hp)
    if status == DEAD then
        self.emitter:emit('dead', self)
    end
end

return Player
