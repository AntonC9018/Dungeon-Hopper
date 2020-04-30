local utils = require("logic.action.movs.utils")

local getMovs = function(actor, action)

    local player = utils.getClosestPlayer(actor)

    if player == nil then 
        return {} 
    end

    local gx, gy, lx, ly = utils.calculateRelativeness(actor, player)
 
    -- So this is basically if-you-look-to-the-left,
    -- you-would-prefer-to-go-to-the-left action
    local movs = {}

    local addMov = function(x, y) table.insert(movs, Vec(x, y)) end

    if actor.orientation.x > 0 then -- looking right
        -- prioritize going to the right
        if gx then addMov( 1,  0) end
        if gy then addMov( 0,  1) end
        if ly then addMov( 0, -1) end
        if lx then addMov(-1,  0) end

    elseif actor.orientation.x < 0 then -- looking left
        -- prioritize going to the left
        if lx then addMov(-1,  0) end
        if gy then addMov( 0,  1) end
        if ly then addMov( 0, -1) end
        if gx then addMov( 1,  0) end

    elseif actor.orientation.y > 0 then -- looking down
        --- ...
        if gy then addMov( 0,  1) end
        if gx then addMov( 1,  0) end
        if lx then addMov(-1,  0) end
        if ly then addMov( 0, -1) end

    elseif actor.orientation.y < 0 then -- looking up
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

    return movs

end


return getMovs