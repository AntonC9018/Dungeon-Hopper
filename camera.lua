Camera = constructor:new{}

function Camera:sync(player, t, cb, x, y, dir)
    transition.to(player.group, {
        x = -(x or player.x) * UNIT + display.contentCenterX,
        y = -(y or player.y) * UNIT + display.contentCenterY,
        transition = easing.inOutSine,
        time = t,
        onComplete = function() if cb then cb(0) end end
    })
end