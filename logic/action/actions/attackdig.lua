
local BasicHandlers = require "logic.action.handlers.basic"
local Action = require "logic.action.action"

local AttackDig = class("AttackDig", Action)

AttackDig.chain = Chain({
    BasicHandlers.Attack,
    BasicHandlers.Dig
})


return AttackDig
