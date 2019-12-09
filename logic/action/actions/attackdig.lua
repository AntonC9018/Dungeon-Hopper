
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"

local AttackDig = class("AttackDig", Action)

AttackDig.type = Action.Types.DIG

AttackDig.chains = {
    nonPlayer = Chain.fromList({ 
        NonPlayerHandlers.Attack,
        NonPlayerHandlers.Dig
    }),
    player = Chain.fromList({
        PlayerHandlers.Attack,
        PlayerHandlers.Dig
    })
}

function AttackDig:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos 
    self.attack = obj.attack
    self.dig = obj.dig
end

return AttackDig
