local Move = class("Move")

function Move:__construct(moveModifier, direction)
    self.isThrough = false
    self.direction = direction
    self.distance = moveModifier.distance or 1
end

Move.posFromMove = function(grid, target, move)
    if move.isThrough then
        return grid:closest(move.target)
    end
    local maxDistance = move.distance
    for i = 1, maxDistance do
        if grid:getRealAt(target.pos + i * move.direction) ~= nil then
            if i == 1 then
                return nil
            else
                return target.pos + (i - 1) * move.direction
            end
        end
    end
    return target.pos + maxDistance * move.direction
end


return Move