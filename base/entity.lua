local Sizeful = require('base.sizeful')
local Animated = require('base.animated')
local Turn = require('logic.turn')
local History = require('logic.history')
local Action = require('logic.action')
local Modifiable = require('logic.modifiable')
local Stats = require('logic.stats')
local HP = require('logic.hp')
local Gold = require('environ.gold')


local Entity = class('Entity', Sizeful, Animated)

-- minimum and maximum amount of damage 
-- that it can take
Entity.min_dmg = 1
Entity.max_dmg = 10

-- reduce each attack damage down by this amount,
-- down to min_dmg
Entity.armor = 0

-- do not take damage if it turned out 
-- lower than this threshold
Entity.dmg_thresh = 1

Entity.priority = 1

-- Basic animation methods (overwritable)
Entity.anims = {
    -- { c = {'dug', 'displaced'},  a = "_displaced" },
    -- { c = {'dug'},               a = "_dug" },
    { c = {'dead'},              a = "_die"},    
    { c = {'displaced', 'hit'},  a = "_displacedHit" },
    { c = {'displaced', 'hurt'}, a = "_displacedHurt" },
    { c = {'displaced'},         a = "_displaced" },
    { c = {'hurt', 'bumped'},    a = "_hurtBumped" },
    { c = {'bumped'},            a = "_bumped" },
    { c = {'hurt'},              a = "_hurt" },
    { c = {'hit'},               a = "_hit" },
    { c = {'stuck'},             a = "_hopUp" },
    { c = {'pushed'},            a = "_bumped" }
}

Entity.innards = { { v = vec(0, 0), e = Gold(50), t = 'gold' } }

function Entity:__construct(x, y, world)
    Sizeful.__construct(self, x, y, world)

    -- previous history
    self.phist = {}
    -- previous position
    self.ppos = {}

    self.facing = vec(0, 0)
    self.hist = History()

    -- logic states
    self.dead = false
    self.moved = false    

    -- self.sliding = false
    -- self.levitating = false

    self.att = Modifiable(Stats(self.att_base))
    self.ams = Modifiable(Stats(self.ams_base))
    self.def = Modifiable(Stats(self.def_base))
    -- buffs or debuffs (decremented by 1 each turn)
    self.buffs = Stats({ invincible = 0 })
    self.hp = HP(self.hp_base)
end

function Entity:reset()
    self.moved = false
    self.phist = self.hist
    self.ppos = self.pos
    self.hist = History()
end


function Entity:tick()
    self.buffs:inc(-1):llim(0)
end

--- Apply damage and special effects to the entity
function Entity:takeHit(a)
    if self.dead then return end

    local t = Turn(a, self)

    -- defend against attack
    local s = a.att - self.def
    
    self:applyDebuffs(s, a, t)

    t:apply()

    -- figure taken damage
    local dmg = self:calcDmg(s, a)
    -- ignore 0 damage
    if dmg <= 0 then return end

    self:takeDmg(dmg, t)
    t:set('hurt'):apply()

    return true
end


function Entity:applyDebuffs(s, a, t)
    if not a.ams then return end
    self.buffs = self.buffs + a.ams * s

    if s:get('push') > 0 and a.ams:get('push') then
        self:push(a.dir:normComps(), a.ams:get('push'), t)
    end
end


function Entity:push(v, am, t)
    self:thrust(v, am, t)
    t:set('pushed')
end


function Entity:dash(v, am, t)
    self:thrust(v, am, t)
    t:set('dashed')
end


-- Apply a thrust in direction of v, am times
function Entity:thrust(v, am, t)

    local blocked = false

    self.world:removeEFromGrid(self)

    for i = 1, am do

        -- get the directions taking into consideration
        -- the sizes of the entity
        local ps = self:getPointsFromDirection(v)

        if not self.world:areBlockedAny(ps) then  
            -- update position
            self:displace(v, t)
        else
            blocked = true
            break
        end
    end

    if blocked then
        t:set('bumped')
    end

    self.world:resetEInGrid(self)

    return t
end

function Entity:attemptMove(a, t) 

    local ps = self:getPointsFromDirection(a.dir)

    if self.world:areBlockedAny(ps) then
        t:set('bumped')
    else
        self:go(a.dir, t)
    end
end

--- Move v and reset the turn accordingly
function Entity:displace(v, t)
    self.pos = self.pos + v
    t:set('displaced')
end

function Entity:go(v, t)
    self.world:removeEFromGrid(self)
    self:displace(v, t)
    self.world:resetEInGrid(self)
end

function Entity:restorePos(pos, t)
    self.world:removeEFromGrid(self)
    self.pos = pos
    self.world:resetEInGrid(self)
end


function Entity:calcDmg(s, a)
    -- if pierced through
    if s:get('pierce') > 0 and s:get('dmg') > 0 then
        local dmg = clamp(s:get('dmg'), self.min_dmg, self.max_dmg)
        if dmg < self.dmg_thresh then return 0 end
        return dmg
    end
    return 0
end


function Entity:takeDmg(dmg, t)
    self.hp:take(dmg)
    print(self.hp)
    
    if self.hp:isEmpty() then
        self.dead = true
        self.moved = true
        self.world:removeEFromGrid(self)
        local cen = self:releaseInnards(t)
        self:deathrattle(t, cen)
        t:set('dead')
    end
end


function Entity:getAttack()
    return self.att
end

function Entity:getAms()
    return self.ams
end


function Entity:bounce(a)
    local ps = self:getPointsFromDirection(a.dir)
    local t = Turn(a, self)

    self.facing = a.dir
    t:set('bounced')

    if self.world:areBlockedAnyAny(ps) then
        if              
            -- if we're not a player
            not self:isPlayer() and
            -- one of the spot has a player
            self.world:havePlayer(ps) and
            -- we intended to attack
            self.seq:is('attack') and
            -- and have not
            not self.hist:was('hit')
        then
            t:set('hit')
            local a = Action(self, 'attack')
                :setDir(a.dir)
                :setAtt(self:getAttack())
                :setAms(self:getAms())

            self.world.player:takeHit(a)
        else
            t:set('bumped')
        end
    
    -- the way is not blocked, move
    else
        self:go(a.dir, t)
    end

    return t:apply()
end

function Entity:releaseInnards()
    -- innards is what's inside of the entity 
    if self.innards then

        local children = {}

        local function trySpawn(x, y, t, e, i)
            if self.world.grid[x][y][t] then
                return false
            else
                children[i] = self.world:spawn(x, y, e, t)
                return true
            end
        end


        for i = 1, #self.innards do
            local p = self.pos + self.innards[i].v
            local t = self.innards[i].t
            local e = self.innards[i].e

            if t == 'gold' then
                self.world:dropGold(p.x, p.y, e)
            else
                if not trySpawn(p.x, p.y, t, e, i) then
                    local f = {
                        vec(1, 0),
                        vec(-1, 0),
                        vec(0, 1),
                        vec(0, -1),
                        vec(1, 1),
                        vec(-1, 1),
                        vec(1, -1),
                        vec(-1, -1)
                    }
                    for j = 1, #f do
                        local np = p + f[j]
                        if trySpawn(np.x, np.y, t, e, i) then
                            break
                        end
                    end
                end
            end
        end
        return children
    end
end

function Entity:deathrattle() end

function Entity:_die(t, ts, cb)
    transition.to(self.sprite, {
        alpha = 0,
        time = 100,
        onComplete = function()
            self.sprite:removeSelf()
        end
    })
    if cb then cb() end
end

function Entity:isObject()
    return false
end

function Entity:isPlayer()
    return false
end

function Entity:isWall()
    return false
end

return Entity