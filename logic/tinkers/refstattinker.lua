local StatTinker = require 'logic.tinkers.stattinker'

local RefStatTinker = class("GutTinker", StatTinker)

function RefStatTinker:__construct(generator)
    StatTinker.__construct(self, generator(self))
end

return RefStatTinker