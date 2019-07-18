Camera = constructor:new{}

function Camera:sync(player, t, cb, x, y)
    transition.to(player.group, {
        x = -(x or player.x) * UNIT + display.contentCenterX,
        y = -(y or player.y) * UNIT + display.contentCenterY,
        transition = easing.linear,
        time = t,
        onComplete = function() if cb then cb(0) end end
    })
end