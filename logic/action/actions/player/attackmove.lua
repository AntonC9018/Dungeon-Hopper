
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action.action"

local AttackMove = class("AttackMove", Action)

AttackMove.chain = Chain({
    PlayerHandlers.Attack,
    PlayerHandlers.Move
})

return AttackMove

