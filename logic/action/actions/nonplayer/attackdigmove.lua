
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local Action = require "logic.action.action"

local AttackDigMove = class("AttackDigMove", Action)

AttackDigMove.chain = Chain({
    PlayerHandlers.Attack,
    PlayerHandlers.Dig,
    PlayerHandlers.Move
})

return AttackDigMove