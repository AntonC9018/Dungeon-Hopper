local Action = require "logic.action.action"
local Chain = require 'lib.chains.chain'

-- the none action means doing nothing
local None = class("NoneAction", Action)

None.chain = {
    player = Chain()
}

return None