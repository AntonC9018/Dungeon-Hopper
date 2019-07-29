local Tile = require('base.tile')
local Stats = require('logic.stats')

local Coals = class('Coals', Tile)

self.att = Stats({ dmg = 2, pierce = 5 })

function Coals:__construct(...)
    self.t = 13
    Tile.__construct(self, ...)
end

function Coals:act()
    local x, y = self.pos:comps()
    local cell = self.world.grid[x][y]
    local e = cell.entity

    if e then
        if 
            self.subject == e and
            not e.hist:was('displaced')
        then
            local a = Action(self, 'hot'):setAtt(self.att)
            e:takeHit(a)
        else
            self.subject = e
        end
    else
        self.subject = false
    end
end

return Coals