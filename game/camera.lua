local Camera = class('Camera')

function Camera:sync(p, t, cb)
    transition.to(p.world.group, {
        x = -(p.pos.x) * SCALE + display.contentCenterX,
        y = -(p.pos.y) * SCALE + display.contentCenterY,
        transition = easing.linear,
        time = t,
        onComplete = function() if cb then cb() end end
    })
end

return Camera