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

Entity.zIndex = 5
Entity.socket_type = 'entity'


-- Basic animation methods (overwritable)
Entity.anims = {
    -- { c = {'dug', 'displaced'},  a = "_displaced" },
    -- { c = {'dug'},               a = "_dug" },
    { c = {'dead'},              a = "_die" },
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

Entity.innards = { { v = vec(0, 0), am = 1, t = 'gold' } }

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

    self.emitter = Emitter()
end

function Entity:reset()
    self.moved = false
    self.phist = self.hist
    self.ppos = self.pos
    self.hist = History()
end


function Entity:tick()
    -- print(string.format( "%s ticking stats [Before]. invincible = %d",
    --     class.name(self), self.buffs:get('invincible')))
    self.buffs:inc(-1):llim(0)
    -- print(string.format( "%s ticking stats [After]. invincible = %d",
    --     class.name(self), self.buffs:get('invincible')))
end

--- Apply damage and special effects to the entity
function Entity:takeHit(a)
    if self.dead then return end

    -- printf("%s is getting hit by %s", class.name(self), class.name(a.actor))

    local t = Turn(a, self)

    -- defend against attack
    local s = a.att - self.def

    self:applyDebuffs(s, a, t)

    t:apply()

    -- do not take damage if invincible
    if self.buffs:get('invincible') > 0 then
        return true
    end

    -- figure taken damage
    local dmg = self:calcDmg(s, a)

    -- ignore 0 damage
    if dmg > 0 then

        -- printf("%s is taking %d damage", class.name(self), dmg)

        self:takeDmg(dmg, t)
        t:set('hurt'):apply()
        self:emit('hit', 'damage:after', dmg, s, a)

    end

    return true
end


function Entity:applyDebuffs(s, a, t)
    if not a.ams then return end
    self.buffs = self.buffs + a.ams * s

    if
        s:get('push') > 0 and
        a.ams:get('push') and
        not self.stuck
    then
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

    -- printf('%s is being displaced. History length: %d', class.name(self), #self.hist:arr())

    self.world:removeFromGrid(self)

    local broke = false

    for i = 1, am do

        -- get the directions taking into consideration
        -- the sizes of the entity
        local ps = self:getPointsFromDirection(v)

        if not self.world:areBlockedAny(ps) then
            -- update position
            self:displace(v, t)
        else
            broke = true
            break
        end
    end

    if broke then
        t:set('bumped')
    end

    self.world:resetInGrid(self)

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
    self:emit('displaced', '', t)
end

function Entity:go(v, t)
    self.world:removeFromGrid(self)
    self:displace(v, t)
    self.world:resetInGrid(self)
end

function Entity:restorePos(pos, t)
    self.world:removeFromGrid(self)
    self.pos = pos
    self.world:resetInGrid(self)
end


function Entity:calcDmg(s, a)
    -- if pierced through
    if
        (
            -- if it's not an explosion
            a.att:get('expl') == 0 or
            -- if it's an unblocked explosion
            (a.att:get('expl') > 0 and s:get('expl') > 0)
        ) and
        -- pierced through armor and done damage
        (s:get('pierce') > 0 and s:get('dmg') > 0)
    then
        -- limit the minimum and maximum amount of damage
        local dmg = clamp(s:get('dmg'), self.min_dmg, self.max_dmg)
        -- ignore damage below the threshold
        if dmg < self.dmg_thresh then return 0 end
        return dmg
    end
    return 0
end


function Entity:takeDmg(dmg, t)
    self.hp:take(dmg)
    print(string.format('%s\'s health: %s', class.name(self), tostring(self.hp)))
    if self.hp:isEmpty() then
        self.dead = true
        self.moved = true
        self.world:removeFromGrid(self)
        local cen = self:releaseInnards(t)
        self:deathrattle(cen, t)
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
    local t = Turn(a, self)
    t:set('bounced')

    self.facing = a.dir

    -- printf('%s trying to bounce', class.name(self))


    if
        not self:isPlayer() and
        -- we intended to attack
        self.seq:is('attack') and
        -- and have not
        not self.hist:was('hit')
    then
        -- prepare the attack
        local action = Action(self, 'attack')
            :setDir(a.dir)
            :setAtt(self:getAttack())
            :setAms(self:getAms())

        -- attempt to attack
        if self.weapon then
            self.weapon:attemptAttack(action, t)
        end

        -- attack not successful
        if not t.hit then
            self:thrust(a.dir, 1, t)
        end

    else
        self:thrust(a.dir, 1, t)
    end

    t:apply()
end


function Entity:releaseInnards()
    -- innards is what's inside of the entity
    if self.innards then

        local children = {}

        local function trySpawn(p, t, cl, i)
            local x, y = p:comps()
            if self.world.grid[x][y][t] then
                return false
            else
                children[i] = self.world:spawn(x, y, cl, t)
                return true
            end
        end


        for i = 1, #self.innards do
            local pos = self.pos + self.innards[i].v
            local type = self.innards[i].t

            if type == 'gold' then
                local g = Gold(self.innards[i].am)

                self:untilTrue('animation',

                    function(current_event, current_turn)

                        if
                            current_turn.dead and
                            current_event == 'step:complete'
                        then
                            g:appear()
                            return true
                        end

                    end)

            else
                local classname = self.innards[i].cl

                if not trySpawn(pos, type, classname, i) then
                    local f = {
                        vec( 0,  0),
                        vec( 1,  0),
                        vec(-1,  0),
                        vec( 0,  1),
                        vec( 0, -1),
                        vec( 1,  1),
                        vec(-1,  1),
                        vec( 1, -1),
                        vec(-1, -1)
                    }
                    for j = 1, #f do
                        local new_pos = self.pos + f[j]
                        if trySpawn(new_pos, type, classname, i) then
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

function Entity:isEnemy()
    return false
end

function Entity:on(...)
    self.emitter:on(...)
end

function Entity:once(...)
    self.emitter:once(...)
end

function Entity:emit(...)
    self.emitter:emit(...)
end

function Entity:untilTrue(...)
    self.emitter:untilTrue(...)
end

function Entity:getRace()
    return 'none'
end

return Entity