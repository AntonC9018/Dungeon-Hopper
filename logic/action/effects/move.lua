local Effect = require 'logic.action.effects.effect'

local Move = class("Move", Effect)

Move.modifier = {
    { 'ignore', 0 },
    { 'distance', 1 }
}

function Move:toPos(grid, target)
    if self.ignore > 0 then
        local t = target.pos + self.direction * self.distance
        if grid:checkBound(t) then
            return t
        else
            return target.pos
        end
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