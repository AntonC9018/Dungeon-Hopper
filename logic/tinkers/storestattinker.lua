-- do the same for stats

local RefStatTinker = require 'logic.tinkers.refstattinker'
local StoreTinker = require 'logic.tinkers.storetinker'

local StoreStatTinker = class('StoreStatTinker', RefStatTinker, StoreTinker)

function StoreStatTinker:__construct(generator)
    self.store = {}
    RefStatTinker.__construct(self, generator)
end

return StoreStatTinker