local Animated = require('animated')

local TileBase = Animated:new()

TileBase:loadAssets(assets.Tile)

function TileBase:__tostring()
    return 'x: '..self.x..', y: '..self.y
end

function TileBase:createSprite()
    self.sprite = display.newImageRect(self.world.group, self.sheet, self.type, 1, 1)
    self.sprite.x = self.x;
    self.sprite.y = self.y;
end

function TileBase:activate() end

function TileBase:reset() end

return TileBase