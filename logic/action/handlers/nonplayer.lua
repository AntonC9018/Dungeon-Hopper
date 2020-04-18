local utils = require 'logic.action.handlers.utils'

-- these are for non-player reals
local Handlers = {}

Handlers.Attack = utils.checkApplyHandler(Chain(), "executeAttack")
Handlers.Move = utils.checkApplyHandler(Chain(), "executeMove")
Handlers.Dig = utils.checkApplyHandler(Chain(), "executeDig")

return Handlers