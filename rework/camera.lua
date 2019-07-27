local Camera = class('Camera')

function Camera:sync(p, cb)
    transition.to(p.world.group, {
        x = -(p.x) * UNIT + display.contentCenterX,
        y = -(p.y) * UNIT + display.contentCenterY,
        transition = easing.linear,
        time = t,
        onComplete = function() if cb then cb() end end
    })
end

return Camera