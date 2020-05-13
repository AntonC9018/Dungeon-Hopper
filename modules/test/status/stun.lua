local Statused = require '@decorators.statused'
local Status = require '@status.status'
local PreventActionTinker = require '.tinkers.preventaction' 
local Overlay = require '@status.overlay'

-- just stop actions
local stun = Status(PreventActionTinker)

stun.amount = 4
stun.overlay = Overlay.RESET

return stun