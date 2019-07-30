local Entity = require('base.entity')
local Turn = require('logic.turn')

local Player = class('Player', Entity)

Player.att_base = {
    dmg = 1,
    pierce = 1,
    dig = 1,
    push = 2
}

Player.def_base = {
    push = 2,
    pierce = 1
}

Player.ams_base = {
    push = 1
}

Player.hp_base = {
    t = 'red',
    am = 6
}

Player.offset = vec(0, -0.4)

Player.priority = 9000000

Player.size = vec(0, 1)


function Player:__construct(...)
    Entity.__construct(self, ...)
    self:createSprite({
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
end

function Player:act(a)

    self.moved = true

    if not a then return end
    
    local t = Turn(a, self)

    a:setAtt(self:getAttack()):setAms(self:getAms())

    if self.stuck then
        -- signalize the stuck causer (a water tile)
        -- to let the player out
        self.stuck:out()
        return r:set('stuck'):apply()
    end

    if a.special then
        -- TODO: implement
    
    else
        -- TODO: implement
        if not a.dir then self:dropBeat() end

        self.facing = a.dir

        -- first attempt to attack/dig
        -- this will also attempt to move, if the weapon spec says so
        local hits = self:attemptAttack(a, t)

        if 
            not self.hist:wasAny('hit', 'dig')
        then
            print('here')
            self:attemptMove(a, t)
        end

        -- TODO: item actions
        -- self:actItems(a, hits)

        -- if neither moved nor attacked, drop beat
        -- if 
        --     not self.hist:wasAny('displaced', 'hit')
        -- then
        -- self:dropBeat()
        -- end

        t:apply()

    end
end

function Player:dropBeat()
end


function Player:attemptAttack(a, t)    

    -- perform the attack defined by the weapon spec
    if self.weapon then
        return self.weapon:attemptAttack(a, t)
    end

    local ps = self:getPointsFromDirection(a.dir)

    -- try to bump
    if self.world:areBlockedAny(ps) then
        t:set('bumped')
    end

    return {}
end


function Player:equip(w)
    -- self.weapon:retractModification(self)
    self.weapon = w
    -- self.weapon:applyModification(self)
end


function Player:reset()
    Entity.reset(self)
    -- stop flickering
    if self.buffs:get('invincible') <= 0 and self.flicker then
        -- stop flickering
        transition.cancel(self.flicker)
        -- restore alpha
        transition.to(self.sprite, {
            alpha = 1,
            time = 100
        })
        self.sprite.alpha = 1
    end
end


function Player:isPlayer()
    return true
end

function Player:_hit(t, ts, cb)
    if self.weapon then
        self.weapon:playAnimation(t, ts)
        self.weapon:playAudio()
    end
    if cb then cb() end
end


return Player