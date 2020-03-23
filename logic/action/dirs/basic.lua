local calculateRelativeness = require("logic.action.dirs.utils").calculateRelativeness

local getMovs = function(actor, action)

    local gx, gy, lx, ly = calculateRelativeness(actor)
 
    -- So this is basically if-you-look-to-the-left,
    -- you-would-prefer-to-go-to-the-left action
    local dirs = {}

    local addMov = function(x, y) table.insert(dirs, Vec(x, y)) end

    if actor.facing.x > 0 then -- looking right
        -- prioritize going to the right
        if gx then addMov( 1,  0) end
        if gy then addMov( 0,  1) end
        if ly then addMov( 0, -1) end
        if lx then addMov(-1,  0) end

    elseif actor.facing.x < 0 then -- looking left
        -- prioritize going to the left
        if lx then addMov(-1,  0) end
        if gy then addMov( 0,  1) end
        if ly then addMov( 0, -1) end
        if gx then addMov( 1,  0) end

    elseif actor.facing.y > 0 then -- looking down
        --- ...
        if gy then addMov( 0,  1) end
        if gx then addMov( 1,  0) end
        if lx then addMov(-1,  0) end
        if ly then addMov( 0, -1) end

    elseif actor.facing.y < 0 then -- looking up
        --- ...
        if ly then addMov( 0, -1) end
        if gx then addMov( 1,  0) end
        if lx then addMov(-1,  0) end
        if gy then addMov( 0,  1) end

    else -- no direction. Default order!
        -- ...
        if gx then addMov( 1,  0) end
        if lx then addMov(-1,  0) end
        if gy then addMov( 0,  1) end
        if ly then addMov( 0, -1) end
    end

    return dirs

end


return getMovs