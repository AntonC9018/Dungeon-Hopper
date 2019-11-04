local Trap = require('base.trap')
local Action = require('logic.action')
local Stats = require('logic.stats')

local BounceTrap = class('BounceTrap', Trap)

function BounceTrap:__construct(dir, ...)
    Trap.__construct(self, ...)
    if dir.x == 0 and dir.y == 0 then dir = Vec(1, 0) end
    self.dir = dir

    -- rotate the sprites according to dir
    -- by default, they look to the left
    -- ?figure another way?
    local rad = Vec.angleBetween(Vec(1, 0), self.dir)
    local deg = math.deg(rad)
    self.sprite_unpushed.rotation = deg
    self.sprite_pushed.rotation = deg
end

function BounceTrap:act()

    -- printf('BounceTrap at (%d, %d) gets the turn. ', self.pos.x, self.pos.y)

    local entity_before = self.subject

    Trap.act(self)

    if entity_before ~= self.subject and self.subject then
        local subj = self.subject

        local a = Action(self, 'bounce'):setDir(self.dir)

        printf('%s bounces %s', class.name(self), class.name(subj))
        subj:bounce(a)

        local x, y = subj.pos:comps()
        local trap = self.world.grid[x][y].trap

        if trap and not trap.pushed and not trap.moved then
            print('Making another trap act')
            trap:act()
        end
    end

end

return BounceTrap