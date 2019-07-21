local Entity = require('entity')
local constructor = require('constructor')


local Object = constructor.new(Entity, {
    dmg_res = 15,
    push_res = 0,
    health = 1,
    pierce_res = 2,
    moved = true,
    priority = -1,
    doing_action = true
})

function Object:new(...)
    local o = Entity.new(self, unpack(arg))
    return o
end

function Object:isObject()
    return true
end

function Object:anim() end
function Object:playAudio() end
function Object:computeAction() end
function Object:setAction() end

function Object:_hurt(...)
    self:_hopUp(...)
end

function Object:_pushed(t, ts, cb)
    Object._displaced(self, t, ts, cb)
end

return Object

