
local BasicHandlers = require "@action.handlers.basic"
local Action = require "@action.action"

local AttackDig = class("AttackDig", Action)

AttackDig.chain = Chain({
    BasicHandlers.Attack,
    BasicHandlers.Dig
})


return AttackDig
