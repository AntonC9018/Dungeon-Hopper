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

Player.priority = 9000000
Player.anims = {}
Player.anims['displaced'] = "_displaced"

function Player:__construct()
    Entity.__construct(self)
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

    if self.stuck then
        -- signalize the stuck causer (a water tile)
        -- to let the player out
        self.stuck:getOut()
        return r:set('stuck'):apply()
    end

    if a.special then
        -- TODO: implement
    
    else
        -- TODO: implement
        if not a.dir then self:dropBeat() end

        -- first attempt to attack/dig
        -- this will also attempt to move, if the weapon spec says so
        local hits = self:attemptAttack(a, t)

        if 
            not self.hist:wasAny('hit', 'dig')
        then
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
    if self.world:areBlocked(ps) then
        t:set('bumped')
    end

    return {}
end

function Player:attemptMove(a, t) 

    local ps = self:getPointsFromDirection(a.dir)

    if self.world:areBlocked(ps) then
        t:set('bumped')
    else
        self.world:removeEFromGrid(self)
        self:displace(a.dir, t)
        self.world:resetEInGrid(self)
    end
end


function Player:equip(w)
    self.weapon:retractModification(self)
    self.weapon = w
    self.weapon:applyModification(self)
end


function Player:reset()
    -- stop flickering
    if self.buffs.invincible <= 0 and self.flicker then
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


return Player