
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action.action"

local AttackDigMove = class("AttackDigMove", Action)

AttackDigMove.chain = Chain({
    PlayerHandlers.Attack,
    PlayerHandlers.Dig,
    PlayerHandlers.Move
})

return AttackDigMove