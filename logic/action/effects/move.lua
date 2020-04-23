local Move = class("Move")

function Move:__construct(moveModifier, direction)
    self.isThrough = false
    self.direction = direction
    self.distance = moveModifier.distance or 1
end

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