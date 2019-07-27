local Weapon = class("Weapon", Displayable)

Weapon.move_attack = false
Weapon.hit_all = false
Weapon.frail = false

Weapon.pos = vec(0, 0)

function Weapon:__construct(o)
    self:createSprite(o)
    -- TODO: gfjqklew
end

function Weapon:attemptAttack(a, t)

    if self.move_attack then
        a.actor:attemptMove(a, t)
    end

    local pat = self:getPattern(a, t)
    local knockb = self:getKnockb(a, t)

    local hits = {}
    local blocked = {}
    local objs = {}

    local ihat = a.dir
    local jhat = ihat:rotate(-math.pi / 2)

    t:apply()

    for i = 1, #pat do
        local dir =   pat[i]:matmul(ihat, jhat)
        local kndir = knockb[i]:matmul(ihat, jhat)
        local ps =    self:patternDirToPoints(dir, a)

        for j = 1, #ps do
            local x, y = ps:comps()
            local cell = self.world.grid[x][y]

            if 
                cell.entity and
                cell.entity ~= a.actor and
                self:canReach(a, blocked, i)
            then

                local a = a:copy():setDir(kndir)

                local y = { a, dir, cell, ps[j], i }

                self:modify( unpack(y) )

                if
                    self:isTargetingObject(a, dir, cell)
                then
                    table.insert(objs, y)
                else
                    self:orient(dir, pat[i], i)
                    self:attack( unpack(y) )
                    table.insert(hits, cell.entity)
                    t:set('hit')
                end
            end

            blocked[i] =
                blocked[i] or
                w.grid[x][y].wall or
                (w.grid[x][y].entity and w.grid[x][y].entity:isObject())

            if not self.hit_all and t.hit then
                return hits
            end
        end
    end

    if #hits > 0 then
        t:set('hit')
        for i = 1, #objs do
            self:attack(objs[i])
        end
    end

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
        return p.pos + dir
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
        local ps = p:getPointsFromDirection(d, w)
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

function Weapon:isTargetingObject(dir, cell, a)
    return
        cell.entity:isObject() and not
        ((dir.x == 0 and dir.y ~= 0) or
         (dir.x ~= 0 and dir.y == 0)) and
        a.actor:isClose(cell.entity)
end


function Weapon:attack(a, dir, cell, ps, i)
    cell.entity:takeHit(a)
end

function Weapon:modify(a, dir, cell, ps, i)
end

function Weapon:getPattern(a, t)
    return self.pattern
end

function Weapon:getKnockb(a, t)
    return self.knockb
end

function Weapon:playAudio()
    audio.play(self.audio['swipe'])
end

function Weapon:playAnimation(t)
    self:anim(t, 'swipe')
end

return Weapon