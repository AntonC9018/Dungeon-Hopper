local StatTinker = require '@tinkers.stattinker'

local RefStatTinker = class("RefTinker", StatTinker)

function RefStatTinker:__construct(generator)
    StatTinker.__construct(self, generator(self))
end

return RefStatTinker