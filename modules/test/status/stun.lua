local Statused = require 'logic.decorators.statused'
local Status = require 'logic.status.status'
local PreventActionTinker = require 'modules.test.tinkers.preventaction' 
local Overlay = require 'logic.status.overlay'

-- just stop actions
local stun = Status(PreventActionTinker)

-- register the new stat
Statused.registerStatus('stun', stun)

stun.amount = 4
stun.overlay = Overlay.RESET

return stun