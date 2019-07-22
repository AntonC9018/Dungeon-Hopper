local Entity = require('entity')
local constructor = require('constructor')

local Wall = constructor.new(Entity, {
    dig_res = 1,
    offset_y = -0.3,
    scaleX = 1 / 16,
    scaleY = 1 / 12
})

function Wall:new(...)
    local o = constructor.new(self, ...)
    o:createSprite()
    return o
end

function Wall:anim() end
function Wall:playAudio() end
function Wall:destroy()
    self.sprite:removeSelf()
end

return Wall