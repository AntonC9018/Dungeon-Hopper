
local utils = require '@action.handlers.utils'

local Handlers = {}

Handlers.Attack = utils.applyHandler("executeAttack")
Handlers.Move = utils.applyHandler("executeMove")
Handlers.Dig = utils.applyHandler("executeDig")

return Handlers