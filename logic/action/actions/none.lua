
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"


-- the none action means doing nothing
local None = class("NoneAction", Action)

function None:__construct()
    self.type = Action.Types.NONE
end

return None