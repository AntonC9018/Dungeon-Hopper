local constructor = require('constructor')
local Wall = require('walls.wall')

local Dirt = constructor.new(Wall, {
    dig_res = 1
})

function Dirt:createSprite()
    self.sprite = display.newImageRect(self.world.group, self.sheet, 1, 16, 20)
    self:setupSprite()
end

Dirt:loadAssets(assets.Dirt)

return Dirt