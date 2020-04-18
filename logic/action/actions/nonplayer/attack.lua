
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local Action = require "logic.action.action"

local Attack = class("AttackAction", Action)

Attack.chain = Chain({ 
    NonPlayerHandlers.Attack 
})

return Attack