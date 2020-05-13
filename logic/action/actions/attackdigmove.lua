
local BasicHandlers = require "@action.handlers.basic"
local Action = require "@action.action"

local AttackDigMove = class("AttackDigMove", Action)

AttackDigMove.chain = Chain({
    BasicHandlers.Attack,
    BasicHandlers.Dig,
    BasicHandlers.Move
})

return AttackDigMove