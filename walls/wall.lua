local Entity = require('entity')
local constructor = require('constructor')

local Wall = constructor.new(Entity, {
    dig_res = 1,
    offset_y = -3/16,
    scaleX = 1 / 16,
    scaleY = 1 / 16,
    priority = -1
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
    self.dead = true
end
function Wall:computeAction() end
function Wall:performAction()
    self.moved = true
end
function Wall:resetPositions() end
function Wall:playAnimation(w, cb) cb() end



return Wall