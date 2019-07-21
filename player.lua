local Entity = require('entity')
local HP = require('hp')
local Turn = require('turn')
local Attack = require('attack')
local constructor = require('constructor')


local Player = constructor.new(Entity, {
    offset_y = -0.4,
    offset_y_jump = -0.2,
    invincible = 0,
    invincible_max = 2,
    pierce_ing = 1,
    push_amount = 1,
    push_ing = 1,
    size = { 1, 1 },
    priority = 1    
})

Player:loadAssets(assets.Player)

function Player:new(...)
    local o = Entity.new(self, unpack(arg))
    o.hp = HP:new():set('red', 6)
    o.to_drop = {}
    o.items = {}
    o:createSprite()
    o:on('hurt:damage', function(p, w)        

        -- taking damage drops beat
        p:dropBeat()

        -- start flickering
        p.flicker = transition.to(p.sprite, {
            alpha = 0,
            transition = easing.continuousLoop,
            time = 200,
            iterations = 0
        })
        -- reset fliker count
        p.invincible = p.invincible_max
    end)
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
    self:setupSprite()
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

        local enemy, wall, moved

        local function _at()
            enemy = self:attack(a, t, w)
        end
        local function _di()
            wall = self:dig(a, t, w)
        end
        local function _mo()
            moved = self:move(a, t, w)
        end 
        local function app()
            t:apply(); t = Turn:new(self, a)
        end
        local function at()
            _at() app()
        end
        local function di()
            _di() app()
        end
        local function mo()
            _mo() app()
        end
        local function ma()
            return self.weapon and self.weapon.move_attack
        end
        local function md()
            return self.spade  and self.spade.move_dig
        end
        local function dm()
            return self.spade  and self.weapon.dig_move
        end
        local function am()
            return self.weapon and self.weapon.attack_move
        end
        local function cm()
            return not areBlocked(self:getPointsFromDirection(a), w)
        end


        -- can move and then attack
        if ma() then
            -- way not blocked
            if cm() then 
                -- move
                _mo()
                -- attempt attack
                at()
            else
                -- attempt attack
                at()
            end
        else
            -- attempt attack
            at()
        end
        -- hasn't attacked
        if not enemy then
            -- can move and dig
            if md() then
                -- way not blocked
                if cm() and not moved then
                    -- move
                    _mo()
                    -- attempt dig
                    di()
                elseif not enemy then
                    -- attempt dig
                    di()
                end
            else
                di()
            end            
        end
        if 
            -- can move after digging / attacking and done some
            (am() and dm() and (enemy or wall)) or
            -- can move after attacking and did attack
            (am() and enemy and not wall) or
            -- can move after digging and did dig
            (dm() and not enemy and wall) or
            -- did neither dig nor attack nor move
            (not enemy and not wall and not moved)
        then
            -- attempt to move
            mo()
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

    -- if no weapon, bump
    if areBlocked(self:getPointsFromDirection(dir), w) then
        t:set('bumped')
        self.emitter:emit('attack:bump', self, dir)
        return true
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

    if self.spade then
        return self.spade:attemptDig(dir, t, w, self)
    end

    -- no spade, bump
    if areBlocked(self:getPointsFromDirection(dir), w) then
        t:set('bumped')
        self.emitter:emit('dig:bump', self, dir)
        return true
    end

    return false
end

-- attempt to move
function Player:move(dir, t, w)       
    -- there is no enemies in the way
    if not areBlocked(self:getPointsFromDirection(dir), w)  
    then
        -- go forward
        self:go(dir, t, w)
        self.emitter:emit('move:displaced', self, dir)
        return true
    else
        t:set('bumped')
        self.emitter:emit('move:bump', self, dir)   
        return false     
    end
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
    self.weapon:playAnimation(ts)
    self.weapon:playAudio()
    if cb then cb() end
end


function Player:_dashedHit(t, ts, cb)
    self:_hit(t, ts)
    self:_displaced(t, ts, cb)
end

function Player:_dug(t, ts, cb)
    self:playAudio('dig')
    if self.spade then
        self.spade:playAnimation(ts)
        self.spade:playAudio()
    end
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
