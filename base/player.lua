local Entity = require('base.entity')
local Inventory = require('logic.inventory')
local Turn = require('logic.turn')

local Player = class('Player', Entity)

Player.att_base = {
    dmg = 3,
    pierce = 1,
    dig = 2,
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
    am = 60
}

Player.offset = vec(0, -0.4)

Player.priority = 9000000

Player.size = vec(0, 0)


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

    self:on('hit', function(event)
        if event == 'damage:after' then
            self.buffs:setStat('invincible', 2)
            self:dropBeat()
            self.flicker = transition.to(self.sprite, {
                alpha = 0,
                transition = easing.continuousLoop,
                time = 200,
                iterations = 0
            })
        end
    end)


    self:on('animation', function(event, t, i)
        if event == 'step:complete' then
            -- take gold or items
            if t.pickup then
                for i = 1, #t.pickups do
                    t.pickups[i]:pickup()

                    if class.name(t.pickups[i]) == 'Gold' then
                        -- TODO: animate the incrementing of gold
                    end
                end
            end
        end
    end)



    self.inventory = Inventory()
end

function Player:act(a)

    self.moved = true

    -- alias the weapon to make API the same for
    -- the player and the enemies
    self.weapon = self.inventory:get('weapon'):get(1)
    self.shovel = self.inventory:get('shovel'):get(1)

    if not a then return end

    local t = Turn(a, self)

    a:setAtt(self:getAttack()):setAms(self:getAms())

    if self.stuck then
        -- signalize the stuck causer (a water tile)
        -- to let the player out
        self.stuck:out()
        return t:set('stuck'):apply()
    end

    if a.special then
        -- TODO: implement

    else
        -- TODO: implement
        if not a.dir then return self:dropBeat() end

        self.facing = a.dir

        -- first attempt to attack/dig
        -- this will also attempt to move, if the weapon spec says so
        local hits = self:attemptAttack(a, t)

        t:apply()
        t = Turn(a, self)

        if
            not self.hist:was('hit')
        then
            self:attemptDig(a, t)
            t:apply()
            t = Turn(a, self)

            if
                not self.hist:wasAny('dug', 'displaced')
            then
                self:attemptMove(a, t)
                t:apply()
                t = Turn(a, self)
            end

            if
                not self.hist:was('dugout')
            then
                self:dropBeat()
            end
        end


        if
            not self.hist:wasAny('hit', 'dug', 'displaced')
        then
            self:attemptBump(a, t)
            t:apply()
            t = Turn(a, self)
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
end

function Player:attemptDig(a, t)

    -- perform the attack defined by the weapon spec
    if self.shovel then
        return self.shovel:attemptDig(a, t)
    end
end

function Player:attemptBump(a, t)

    local ps = self:getPointsFromDirection(a.dir)

    if self.world:areBlockedAny(ps) then
        t:set('bumped')
    end

end


-- function Player:equip(w)
--     -- self.weapon:retractModification(self)
--     self.weapon = w
--     -- self.weapon:applyModification(self)
-- end


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


return Player