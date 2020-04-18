
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action.action"

local Move = class("MoveAction", Action)

Move.chain = Chain({
    PlayerHandlers.Move
})

return Move