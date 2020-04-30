local utils = require("logic.action.movs.utils")

return function(actor, action)
    local player = utils.getClosestPlayer(actor)

    if player == nil then 
        return {} 
    end

    local gx, gy, lx, ly = utils.calculateRelativeness(actor, player)
 
    -- So this is basically if-you-look-to-the-left,
    -- you-would-prefer-to-go-to-the-left action
    local movs = {}

    local addMov = function(x, y) table.insert(movs, Vec(x, y)) end

    if gx then

        if gy then 
            addMov(1, 1) 
            addMov(0, 1) 
        end

        if ly then 
            addMov(1, -1) 
            addMov(0, -1) 
        end

        addMov(1, 0)

    elseif lx then

        if gy then 
            addMov(-1, 1) 
            addMov( 0, 1) 
        end

        if ly then 
            addMov(-1, -1) 
            addMov( 0, -1) 
        end

        addMov(-1, 0)

    -- on one X with the player
    else
        addMov(0, gy and 1 or -1)
    end

    return movs
end