local constructor = require('constructor')
local Wall = require('walls.wall')

local Bedrock = constructor.new(Wall, {
    dig_res = 1,
    offset_y = -9/48
})

function Bedrock:createSprite()
    self.sprite = display.newImageRect(self.world.group, self.sheet, 1, 16, 32)
    self:setupSprite()
end

Bedrock:loadAssets(assets.Bedrock)

return Bedrock