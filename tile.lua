local Animated = require('animated')

local Tile = Animated:new{
    width = UNIT
}

Tile:loadAssets(assets.Tile)

function Tile:new(...)
    local o = Animated.new(self, ...)
    o:createSprite()
    return o
end


function Tile:__tostring()
    return 'x: '..self.x..', y: '..self.y
end

function Tile:createSprite()
    self.sprite = display.newImageRect(self.world.group, self.sheet, self.type, 1, 1)
    self.sprite.x = self.x;
    self.sprite.y = self.y;
end

return Tile