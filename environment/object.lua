local Entity = require('entity')

local Object = Entity:new({
    dmg_res = 3,
    push_res = 0,
    health = 1,
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

function Object:computeAction() end
function Object:setAction() end

return Object

