local Displayable = require('base.displayable')

local BasicTile = class('Tile', Displayable)

BasicTile.offset = vec(0, 0)

function BasicTile:__construct(x, y, t, world)
    Displayable.__construct(self, x, y, world)
    self:createImage(t, UNIT, UNIT)
end

return BasicTile