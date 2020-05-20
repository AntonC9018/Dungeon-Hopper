local OptionStatus = require '@status.option'
local utils = require '@tinkers.utils'

-- By definition, a flavor is a tinker component
-- it must include the rank or a priority number with the handler
-- it assumes you're using a StoreTinker

local FlavorStatus = class('FlavorStatus', OptionStatus)


function FlavorStatus:apply(entity, amount, options)
    OptionStatus.apply(self, entity, amount, options)
    -- now, apply the flavor part
    local flavors = options.flavors or { options.flavor }
    for _, f in ipairs(flavors) do
        utils.tink(entity, f[1], f[2])
    end
end

function FlavorStatus:wearOff(entity, amount)
    local options = self.tinker:getStore(entity)
    local flavors = options.flavors or { options.flavor }
    for _, f in ipairs(flavors) do
        utils.untink(entity, f[1], f[2][1])
    end
    OptionStatus.wearOff(self, entity, amount)    
end


return FlavorStatus

