local Spade = require('spades.spade')

local WoodenSpade = Spade:new()

function WoodenSpade:dig(obj)
    local t = Spade.dig(self, obj)
    if t then
        self:destroy()
    end
end

return WoodenSpade