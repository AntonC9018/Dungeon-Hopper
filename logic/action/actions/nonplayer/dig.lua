
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local Action = require "logic.action.action"

local Dig = class("DigAction", Action)

Dig.chain = Chain({ 
    NonPlayerHandlers.Dig
})

return Dig
