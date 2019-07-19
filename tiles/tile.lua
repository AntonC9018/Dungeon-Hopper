local TileBase = require('tiles.tileBase')

Tile = TileBase:new{}

function Tile:new(...)
    local o = TileBase.new(self, unpack(arg))
    o:createSprite()
    return o
end

return Tile