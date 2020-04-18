
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action.action"

local Attack = class("AttackAction", Action)

Attack.chain = Chain({
    PlayerHandlers.Attack
})

return Attack