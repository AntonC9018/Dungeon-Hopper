local Effect = require 'logic.action.effects.effect'

local Move = class("Move", Effect)

Move.modifier = {
    { 'isThrough', false },
    { 'distance', 1 }
}

function Move:toPos(grid, target)
    if self.isThrough then
        return grid:closest(self.target)
    end

    local maxDistance = self.distance
    for i = 1, maxDistance do
        local testPos = target.pos + i * self.direction
        if 
            grid:hasBlockAt(testPos)
        then
            if i == 1 then
                return target.pos
            else
                return target.pos + (i - 1) * self.direction
            end
        end
    end

    return target.pos + maxDistance * self.direction
end


return Move