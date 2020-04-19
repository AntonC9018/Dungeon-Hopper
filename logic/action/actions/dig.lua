
local BasicHandlers = require "logic.action.handlers.basic"
local Action = require "logic.action.action"

local Dig = class("DigAction", Action)

Dig.chain = Chain({
    BasicHandlers.Dig
})

return Dig
