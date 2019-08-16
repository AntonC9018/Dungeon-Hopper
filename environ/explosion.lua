local Displayable = require('base.displayable')
local Stats = require('logic.stats')
local Action = require('logic.action')

local Explosion = class('Explosion', Displayable)

Explosion.offset = vec(0, 0)

Explosion.att = Stats({ dmg = 4, push = 10, pierce = 2, expl = 10, dig = 4 })
Explosion.ams = Stats({ push = 1 })

-- how many frames the explosion fades away
Explosion.numFrames = 3

function Explosion:__construct(kndir, ...)
    Displayable.__construct(self, ...)
    self:createImage(1, UNIT, UNIT)
    self.framecount = 1
    self.kndir = kndir
end


function Explosion:playAnimation(cb)

    self.sprite:removeSelf()
    
    if not self.dead then
        self:createImage(self.framecount, UNIT, UNIT)
    end

    cb()
end


function Explosion:explode()
    local x, y = self.pos:comps()
    local cell = self.world.grid[x][y]

    local a = Action(self, 'expl')
        :setAtt(self.att)
        :setDir(self.kndir)
        :setAms(self.ams)


    if cell.wall then
        -- attack the wall
        cell.wall:takeHit(a)
    end

    if cell.entity then
        cell.entity:takeHit(a)
    end
end


function Explosion:tick()
    self.framecount = self.framecount + 1
    if self.framecount > self.numFrames then
        self.dead = true
    end
end

return Explosion