
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action.action"

local AttackDig = class("AttackDig", Action)

AttackDig.chain = Chain({
    PlayerHandlers.Attack,
    PlayerHandlers.Dig
})


return AttackDig
