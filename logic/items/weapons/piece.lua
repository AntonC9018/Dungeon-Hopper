-- pos is the relative to the attacker coordinate
local Piece = class("Piece")

function Piece:__construct(pos, dir, reach)
    self.pos = pos
    self.dir = dir
    self.reach = reach
end

function Piece:transform(ihat, jhat)
    return Piece(
        self.pos:matmul(ihat, jhat),
        self.dir:matmul(ihat, jhat),
        self.reach
    )
end

return Piece