
local BasicHandlers = require "logic.action.handlers.basic"
local Action = require "logic.action.action"

local Attack = class("AttackAction", Action)

Attack.chain = Chain({
    BasicHandlers.Attack
})

return Attack