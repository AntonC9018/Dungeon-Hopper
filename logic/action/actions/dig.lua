
local BasicHandlers = require "@action.handlers.basic"
local Action = require "@action.action"

local Dig = class("DigAction", Action)

Dig.chain = Chain({
    BasicHandlers.Dig
})

return Dig
