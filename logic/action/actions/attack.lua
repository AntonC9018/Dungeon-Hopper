
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"

local Attack = class("AttackAction", Action)

Attack.type = Action.Types.ATTACK

Attack.chains = {
    nonPlayer = Chain.fromList({ 
        NonPlayerHandlers.Attack 
    }),
    player = Chain.fromList({
        PlayerHandlers.Attack
    })
}

function Attack:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos
    self.attack = obj.attack 
end

return Attack