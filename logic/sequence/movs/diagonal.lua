local utils = require("logic.sequence.movs.utils")

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

    -- to the left of the player
    if gx then
        if     gy then addMov(1,  1)
        elseif ly then addMov(1, -1)
        else
            -- we're on one X with the player
            if self.orientation.y > 0 then
                addMov(1,  1)
                addMov(1, -1)
            else
                addMov(1, -1)
                addMov(1,  1)
            end
        end

    -- to the right of the player
    elseif lx then
        if     gy then addMov(-1,  1)
        elseif ly then addMov(-1, -1)
        else
            -- we're on one X with the player
            if self.orientation.y > 0 then
                addMov(-1,  1)
                addMov(-1, -1)
            else
                addMov(-1, -1)
                addMov(-1,  1)
            end
        end

    -- on one Y with the player
    -- higher than the player
    elseif gy then
        if self.orientation.x > 0 then
            addMov(-1,  1)
            addMov( 1,  1)
        else
            addMov( 1,  1)
            addMov(-1,  1)
        end

    -- lower than the player
    else
        if self.orientation.x > 0 then
            addMov(-1, -1)
            addMov( 1, -1)
        else
            addMov( 1, -1)
            addMov(-1, -1)
        end
    end

    return movs
end