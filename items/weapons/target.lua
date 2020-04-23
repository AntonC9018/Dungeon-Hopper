
local Target = class("Hit")

function Target:__construct(entity, piece, index, attackableness)
    self.entity = entity
    self.piece = piece
    self.index = index
    self.attackableness = attackableness
end

return Target