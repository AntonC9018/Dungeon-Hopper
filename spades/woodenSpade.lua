local Spade = require('spades.spade')

local WoodenSpade = Spade:new()

function WoodenSpade:digWall(obj)
    local t = Spade.digWall(self, obj)
    if t then
        -- self:destroy()
    end
    return t
end

return WoodenSpade