local Object = require('environment.object')

local Crate = Object:new({
    offset_y = -0.2,
    offset_y_jump = -0.3,
    offset_y_hop = -0.3
})

Crate:loadAssets(assets.Crate)

function Crate:new(...) 
    local o = Object.new(self, unpack(arg))
    o.scaleX = o.scaleX * 0.75
    o.scaleY = o.scaleY * 0.75
    o:createSprite()
    return o
end

function Crate:createSprite()
    self.sprite = display.newImageRect(self.world.group, self.sheet, 1, 16, 20)
    self:setupSprite()
end

return Crate