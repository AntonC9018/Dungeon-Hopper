local constructor = require('constructor')
local Camera = constructor:new{}

function Camera:sync(obj, t, cb, x, y)
    transition.to(obj.world.group, {
        x = -(x or obj.x) * UNIT + display.contentCenterX,
        y = -(y or obj.y) * UNIT + display.contentCenterY,
        transition = easing.linear,
        time = t,
        onComplete = function() if cb then cb(0) end end
    })
end

return Camera