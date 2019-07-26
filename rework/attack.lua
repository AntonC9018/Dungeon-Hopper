local Modifiable = require('rework.modifiable')

local Attack = class("Attack", Modifiable)

function Attack:__construct(dir)
    self.dir = dir
end

return Attack