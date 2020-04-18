
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action.action"

local Dig = class("DigAction", Action)

Dig.chain = Chain({
    PlayerHandlers.Dig
})

return Dig
