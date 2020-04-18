
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local Action = require "logic.action.action"

local Move = class("MoveAction", Action)

Move.chain = Chain({ 
    NonPlayerHandlers.Move
})

return Move