
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
    -- self.ams = Modifiable(self.amd_base)
    -- self.def = Modifiable(self.def_base)
    -- buffs or debuffs (decremented by 1 each turn)
    -- self.buffs = Stats()
    -- self.hp = HP(self.hp_base)
end

function Entity:reset()
    self.phist = self.hist
    self.ppos = self.pos.copy()
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


function Entity:takeHit(att, ams)
    if self.dead then return end

    local t = Turn(self, att.push_dir)

    -- defend against attack
    local s = att - self.def
    
    self:applyDebuffs(s, ams, att, t)

    t:apply()

    -- figure taken damage
    local dmg = self:calcDmg(s, ams)
    -- ignore 0 damage
    if dmg <= 0 then return end

    self:takeDmg(dmg)
    t:set('hurt'):apply()

    return true
end


function Entity:applyDebuffs(s, ams, att, t)
    self.buffs = self.buffs + ams * s

    if s.push > 0 and ams.push then
        self:push(att.push_dir:normComps(), ams.push, t)
    end
end


function Entity:push(d, a, t)
    self:thrust(d, a, t)
    t:set('pushed')
end


function Entity:dash(d, a, t)
    self:thrust(d, a, t)
    t:set('dashed')
end


-- apply a thrust in direction of v, a times
function Entity:thrust(v, a, t)

    local blocked = false

    self.world:removeEFromGrid(self)

    for i = 1, amount do

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