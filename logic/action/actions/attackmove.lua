
local BasicHandlers = require "logic.action.handlers.basic"
local Action = require "logic.action.action"

local AttackMove = class("AttackMove", Action)

AttackMove.chain = Chain({
    BasicHandlers.Attack,
    BasicHandlers.Move
})

return AttackMove

