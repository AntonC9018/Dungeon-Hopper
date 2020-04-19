
local BasicHandlers = require "logic.action.handlers.basic"
local Action = require "logic.action.action"

local AttackDigMove = class("AttackDigMove", Action)

AttackDigMove.chain = Chain({
    BasicHandlers.Attack,
    BasicHandlers.Dig,
    BasicHandlers.Move
})

return AttackDigMove