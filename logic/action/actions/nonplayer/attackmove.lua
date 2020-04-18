
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local Action = require "logic.action.action"

local AttackMove = class("AttackMove", Action)

AttackMove.chain = Chain({ 
    NonPlayerHandlers.Attack,
    NonPlayerHandlers.Move
})

return AttackMove

