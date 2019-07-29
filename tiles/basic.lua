local Tile = require('base.tile')

local BasicTile = class('BasicTile', Tile)

function BasicTile:__construct(...)
    self.t = math.random(11)
    Tile.__construct(self, ...)
end

return BasicTile