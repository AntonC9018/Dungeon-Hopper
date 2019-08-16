local Displayable = require('base.displayable')

local Weapon = class("Weapon", Displayable)
Weapon.scale = 1 / UNIT

Weapon.move_attack = false
Weapon.hit_all = true
Weapon.frail = false
Weapon.pos = vec(0, 0)
Weapon.offset = vec(0, 0)

Weapon.att_base = {
    dmg = 1
}

Weapon.pattern = { vec(1, 0) }
Weapon.knockb = { vec(1, 0) }
Weapon.reach = { false }

Weapon.ignore_enemies = false
Weapon.ignore_objects = false
Weapon.ignore_walls = false
Weapon.ignore_players = false

function Weapon:__construct(o, w, s)
    self.world = w
    self:createSprite(o, s)
    self:listenAlpha()
    self.sprite.alpha = 0
    -- TODO: gfjqklew
end

function Weapon:attemptAttack(a, t)

    if self.move_attack then
        a.actor:attemptMove(a, t)
    end

    local hits = {}
    local blocked = {}
    local objs = {}

    local ihat = a.dir
    local jhat = ihat:rotate(-math.pi / 2)

    local w = a.actor.world


    for i = 1, #self.pattern do

        local p = self:getPattern(i, a, t)
        local kn = self:getKnockb(i, a, t)

        if p and kn then

            local dir =   p:matmul(ihat, jhat)
            local kndir = kn:matmul(ihat, jhat)
            local ps =    self:patternDirToPoints(dir, a)

            for j = 1, #ps do
                local x, y = ps[j]:comps()
                local cell = a.actor.world.grid[x][y]
                local a = a:copy():setDir(kndir)
                local y = { a, dir, cell, ps[j], i }


                if
                    -- whether to ignore walls
                    cell.wall and not
                    self.ignore_walls
                then
                    table.insert(hits, y)
                
                elseif
                    -- attacking an enemy / player / object
                    cell.entity and
                    cell.entity ~= a.actor and
                    self:canReach(a, blocked, i)
                then

                    self:modify( unpack(y) )

                    local function doAttack()
                        self:orient(dir, i)
                        self:attack( unpack(y) )
                        table.insert(hits, y)
                        t:set('hit')
                    end

                    if
                        -- if targeting an object
                        cell.entity:isObject() and not
                        self.ignore_objects
                    then
                        if not self:isNextTo(a, dir, cell) then
                            -- store in objs array in case attacking multiple things
                            -- or other side effects
                            table.insert(objs, y)
                        else
                            -- attack the object as standing right next to it
                            doAttack()
                        end
                    
                    elseif
                        cell.entity:isPlayer() and not
                        self.ignore_players
                    then
                        doAttack()
                    
                    elseif
                        cell.entity:isEnemy() and not
                        self.ignore_enemies
                    then
                        doAttack()
                    end
                end

                blocked[i] =
                    blocked[i] or
                    cell.wall or
                    (cell.entity and cell.entity:isObject())
            end
            if not self.hit_all and t.hit then
                break
            end
        end
    end

    if #hits > 0 then
        t:set('hit')
        a.actor.facing = a.dir
        for i = 1, #objs do
            self:attack( unpack(objs[i]) )
            table.insert(hits, objs[i])
        end
    end

    t:apply()


    return hits
end


function Weapon:patternDirToPoints(dir, a)

    local p = a.actor

    if
        -- do not waste computing power if the size
        -- can be neglected, which will be the case
        -- in most scenarios
        p.size.x == 0 and p.size.y == 0
    then
        return { p.pos + dir }
    end

    if
        -- or an orthogonal direction
        (math.abs(dir.x) >= 1 and dir.y == 0) or
        (math.abs(dir.y) >= 1 and dir.x == 0)
    then
        -- get the scale of the vector
        local s = dir:longest()
        -- scale it down to have components = 1
        local d = dir / s
        -- get points out of that
        local ps = p:getPointsFromDirection(d)
        -- rescale the vector
        local v = d * (s - 1)
        -- add to those points that initial vector
        for i = 1, #ps do
            ps[i] = ps[i] + v
        end

        return ps
    end

    -- otherwise we have an irregular pattern like that of a whip
    -- or a diagonal direction
    -- this way the algorithm would yield just one point as the result

    -- We don't care about the size while attacking up or to the left
    -- because the player's anchor point is placed at the upper-left corner
    -- However, when doing it to the right or to the bottom, we'll need
    -- to account for that by adding the player's size to the direction


    if dir.y > 0 then
        dir.y = dir.y + p.size.y
    end

    if dir.x > 0 then
        dir.x = dir.x + p.size.x
    end

    return { p.pos + dir }
end


function Weapon:canReach(a, b, i)
    if
        not self.reach or
        (self.reach and not self.reach[i])
    then
        return true
    end
    return not b[self.reach[i]]
end

function Weapon:isNextTo(a, dir, cell)
    return
        a.actor:isClose(cell.entity) and
        ((dir.x == 0 and dir.y ~= 0) or
        (dir.x ~= 0 and dir.y == 0))
end


function Weapon:attack(a, dir, cell, ps, i)
    cell.entity:takeHit(a)
    self.sprite.x, self.sprite.y = ps:comps()
end

function Weapon:modify(a, dir, cell, ps, i)
end

function Weapon:getPattern(i)
    return self.pattern[i]
end

function Weapon:getKnockb(i)
    return self.knockb[i]
end

function Weapon:listenAlpha()
    self.sprite:addEventListener("sprite", function(event)
        if event.phase == "began" then
            self.sprite:toFront()
            self.sprite.alpha = 1
        elseif event.phase == "ended" then
            self.sprite.alpha = 0
        end
    end)
end

function Weapon:playAudio()
    audio.play(AM[class.name(self)].audio['swipe'])
end

function Weapon:playAnimation(t, ts)
    self:anim(ts, 'swipe')
end

function Weapon:orient(dir, i)
    local a = self:getPattern(i):angleBetween(dir)
    self.sprite.rotation = a * 180 / math.pi
end

function Weapon:getItemType()
    return 'weapon'
end

return Weapon