local Displayable = require('base.displayable')
local Stats = require('logic.stats')
local Action = require('logic.action')

local Explosion = class('Explosion', Displayable)

Explosion.offset = vec(0, 0)

Explosion.att = Stats({ dmg = 4, push = 10, pierce = 2, expl = 10, dig = 4 })
Explosion.ams = Stats({ push = 1 })

-- how many frames the explosion fades away
Explosion.numFrames = 3

Explosion.zIndex = 5

function Explosion:__construct(kndir, ...)
    Displayable.__construct(self, ...)

    self.sprites = {}
    for i = self.numFrames, 1, -1 do
        self.sprites[i] = self:createImage(i, UNIT, UNIT)
        self.sprites[i].alpha = 0
    end
    self.framecount = 1
    self.kndir = kndir
end


function Explosion:playAnimation(cb)

    if not self.dead then
        self:swapImage(self.framecount)
    
    else
        for i = 1, #self.sprites do
            self.sprites[i]:removeSelf()
        end
    end

    cb()
end

function Explosion:swapImage(i)
    self.sprite.alpha = 0
    self.sprite = self.sprites[i]
    self.sprite.alpha = 1
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