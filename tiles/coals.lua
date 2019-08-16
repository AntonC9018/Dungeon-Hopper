local Tile = require('base.tile')
local Stats = require('logic.stats')
local Action = require('logic.action')
local Modifiable = require('logic.modifiable')

local Coals = class('Coals', Tile)

Coals.att = Stats({ dmg = 2, pierce = 5 })

function Coals:__construct(...)
    self.t = 13
    self.subject = false
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
            print(string.format('Coals saved %s', class.name(e)))
        end
    else
        if self.subject then
            print(string.format('Coals removed %s', class.name(self.subject)))
        end
        self.subject = false
    end
end

return Coals