-- do the same for stats
-- Deprecated. probably.

local RefStatTinker = require '@tinkers.refstattinker'
local StoreTinker = require '@tinkers.storetinker'

local StoreStatTinker = class('StoreStatTinker', RefStatTinker, StoreTinker)

function StoreStatTinker:__construct(generator)
    self.store = {}
    RefStatTinker.__construct(self, generator)
end

return StoreStatTinker