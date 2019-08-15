local Tile = require('base.tile')
local Stats = require('logic.stats')

local Water = class('Water', Tile)

Water.att = Stats({ stuck = 5 })

function Water:__construct(...)
    self.t = 12
    Tile.__construct(self, ...)
end

function Water:act()
    local x, y = self.pos:comps()
    local cell = self.world.grid[x][y]
    local e = cell.entity

    if e then
        if (self.att - e.def):get('stuck') > 0 then
            self.subject = e 
            e.stuck = self
        end
    else
        self:out()
    end
end

function Water:out()
    if self.subject then
        self.subject.stuck = false
        self.subject = false
    end
end

return Water