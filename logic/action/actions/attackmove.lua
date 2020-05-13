
local BasicHandlers = require "@action.handlers.basic"
local Action = require "@action.action"

local AttackMove = class("AttackMove", Action)

AttackMove.chain = Chain({
    BasicHandlers.Attack,
    BasicHandlers.Move
})

return AttackMove

