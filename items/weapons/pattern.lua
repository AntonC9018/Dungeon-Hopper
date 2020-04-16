local Piece = require "items.weapons.piece"

local Pattern = class("Pattern")

function Pattern:__construct()
    self.pieces = {}
end

function Pattern:add(pos, dir, reach)
    local piece = Piece(pos, dir, reach)
    table.insert(self.pieces, piece)
    return piece
end

function Pattern:get(i)
    return self.pieces[i]
end

return Pattern