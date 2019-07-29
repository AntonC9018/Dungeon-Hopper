local Entity = require('base.entity')

local Wall = class('Wall', Entity)

Wall.priority = 0
Wall.offset = vec(0, -3 / 16)

Wall.dmg_thresh = 10
Wall.def_base = {
    dig = 1
}

function Wall:isWall()
    return true
end

function Wall:act() end
function Wall:playAnimation(cb) cb() end

return Wall