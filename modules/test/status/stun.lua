local Statused = require 'logic.decorators.statused'
local Status = require 'logic.status.status'
local PreventActionTinker = require 'modules.test.tinkers.preventaction' 

-- just stop actions
local stun = Status(PreventActionTinker)

-- register the new stat
Statused.registerStatus('stun', stun)

return stun