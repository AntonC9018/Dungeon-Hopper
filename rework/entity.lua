
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


function Entity:__construct(x, y, world)
    Sizeful.__construct(self, x, y, world)

    -- previous history
    self.phist = {}
    -- previous position
    self.ppos = {}

    self.facing = { 0, 0 }
    self.hist = History()

    -- logic states
    self.dead = false
    self.moved = false    

    -- self.sliding = false
    -- self.levitating = false

    -- self.att = Modifiable(self.att_base)
    -- self.ams = Modifiable(self.ams_base)
    -- self.def = Modifiable(self.def_base)
    -- buffs or debuffs (decremented by 1 each turn)
    -- self.buffs = Stats()
    -- self.hp = HP(self.hp_base)
end

function Entity:reset()
    self.phist = self.hist
    self.ppos = self.pos:copy()
    self.hist = History()
end


function Entity:tick()
    self.buffs:inc(-1):llim(0)

    -- TODO: implement
    -- local s = self.world:getTileAt(self.x, self.y)

    -- -- got pushed away from the tile or 
    -- -- something wrong happened
    -- if not s or (s and s.subj ~= self) then
    --     self.buffs.stuck = 0
    -- elseif
    --     -- incremented the stuck stat while did not need to
    --     not self.hist:was('stuck')
    --     -- and has been stuck
    --     (s and s.subj == self)
    -- then
    --     self.buffs:incStat('stuck', 1)
    -- end
end

-- a is the action object
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

    self:takeDmg(dmg)
    t:set('hurt'):apply()

    return true
end


function Entity:applyDebuffs(s, a, t)
    self.buffs = self.buffs + a.ams * s

    if s.push > 0 and a.ams.push then
        self:push(a.dir:normComps(), a.ams.push, t)
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


-- apply a thrust in direction of v, am times
function Entity:thrust(v, am, t)

    local blocked = false

    self.world:removeEFromGrid(self)

    for i = 1, am do

        -- get the directions taking into consideration
        -- the sizes of the entity
        local ps = self:getPointsFromDirection(v)

        if not self.world:areBlocked(ps) then  
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


function Entity:displace(v, t)
    self.pos = self.pos + v
    t:set('displaced')
end

function Entity:go(v, t)
    self.world:removeEFromGrid(self)
    self:displace(v, t)
    self.world:resetEInGrid(self)
end



function Entity:calcDmg(s, a)
    -- if pierced through
    if s.pierce > 0 and s.dmg > 0 then
        if s.dmg < self.dmg_thresh then return 0 end
        return clamp(s.dmg, self.min_dmg, self.max_dmg)
    end
    return 0
end


function Entity:takeDmg(dmg)
    self.hp = self.hp - dmg
    
    if self.hp:isEmpty() then
        self.dead = true
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

    if self.world:areBlockedAny(ps) then
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

function Entity:isObject()
    return false
end

function Entity:isPlayer()
    return false
end

return Entity