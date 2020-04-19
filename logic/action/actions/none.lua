local Action = require "logic.action.action"
local Chain = require 'lib.chains.chain'

-- the none action means doing nothing
local None = class("NoneAction", Action)

-- a nil chain is prevented from running the general algo
-- a nil event would immediately run the success chain instead
None.chain = nil

return None