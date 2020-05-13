
local BasicHandlers = require "@action.handlers.basic"
local Action = require "@action.action"

local Attack = class("AttackAction", Action)

Attack.chain = Chain({
    BasicHandlers.Attack
})

return Attack