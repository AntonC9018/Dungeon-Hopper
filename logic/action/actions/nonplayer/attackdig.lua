
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local Action = require "logic.action.action"

local AttackDig = class("AttackDig", Action)

AttackDig.chain = Chain({ 
    NonPlayerHandlers.Attack,
    NonPlayerHandlers.Dig
})

return AttackDig
