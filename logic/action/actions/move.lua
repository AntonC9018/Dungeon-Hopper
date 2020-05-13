
local BasicHandlers = require "@action.handlers.basic"
local Action = require "@action.action"

local Move = class("MoveAction", Action)

Move.chain = Chain({
    BasicHandlers.Move
})

return Move