local Status = require '@status.status'

-- Options are an object with data.
-- this status saves those options when an effect is applied
-- and deletes them once it is removed.

local OptionStatus = class('OptionStatus', Status)

function OptionStatus:apply(entity, amount, options)
    self.tinker:setStore(entity, options)
    self.tinker:tink(entity)
end

function OptionStatus:wearOff(entity, amount)
    self.tinker:removeStore(entity)
    self.tinker:untink(entity)
end

return OptionStatus

