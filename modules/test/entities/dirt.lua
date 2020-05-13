local Wall = require '.base.wall'

local Dirt = class("Dirt", Wall)

Dirt.baseModifiers = {
    hp = {
        amount = 1
    },
    resistance = {
        dig = 0
    }
}

-- no need to copy chains since we're not modifying any

return Dirt