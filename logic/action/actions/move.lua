
local BasicHandlers = require "logic.action.handlers.basic"
local Action = require "logic.action.action"

local Move = class("MoveAction", Action)

Move.chain = Chain({
    BasicHandlers.Move
})

return Move