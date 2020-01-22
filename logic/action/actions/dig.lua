
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"


local Dig = class("DigAction", Action)

Dig.type = Action.Types.DIG

Dig.chains = {
    nonPlayer = Chain.fromList({ 
        NonPlayerHandlers.Dig
    }),
    player = Chain.fromList({
        PlayerHandlers.Dig
    })
}

function Dig:__construct(obj)
    self.direction = obj.direction
    self.dig = obj.dig    
    self.type = Action.Types.DIG
end

return Dig
