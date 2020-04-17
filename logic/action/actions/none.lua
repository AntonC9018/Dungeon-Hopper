
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"


-- the none action means doing nothing
local None = class("NoneAction", Action)

None.type = Action.Types.NONE

None.chains = {
    player = Chain(),
    nonPlayer = Chain()
}

return None