Tile = Entity:new{
    width = UNIT
}

function Tile:__tostring()
    return 'x: '..self.x..', y: '..self.y
end

function Tile:createSprite()
    self.sprite = display.newImageRect(self.group, self.sheet, self.type, 1, 1)
    self.sprite.x = self.x;
    self.sprite.y = self.y;
end