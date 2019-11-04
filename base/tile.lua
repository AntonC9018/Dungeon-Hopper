local Displayable = require('base.displayable')

local Tile = class('Tile', Displayable)

Tile.offset = Vec(0, 0)
Tile.socket_type = 'tile'


function Tile:__construct(x, y, world)
    Displayable.__construct(self, x, y, world)
    self:createImage(self.t, UNIT, UNIT)
end

function Tile:createImage(i, w, h)
    self.sprite = display.newImageRect(self.world.group, AM['Tile'].sheet, i, w, h)
    self:setupSprite(self.pos.x, self.pos.y)
end

function Tile:act() end
function Tile:reset() end

return Tile