
local Target = class("Hit")

function Target:__construct(target, piece, index, attackableness)
    self.target = target
    self.piece = piece
    self.index = index
    self.attackableness = attackableness
end

return Target