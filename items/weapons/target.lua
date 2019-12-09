
local Target = class("Hit")

function Target:__construct(target, piece, index)
    self.target = target
    self.piece = piece
    self.index = index
end

return Target