
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"


local AttackMove = class("AttackMove", Action)

AttackMove.type = Action.Types.ATTACK_MOVE

AttackMove.chains = {
    nonPlayer = Chain.fromList({ 
        NonPlayerHandlers.Attack,
        NonPlayerHandlers.Move
    }),
    player = Chain.fromList({
        PlayerHandlers.Attack,
        PlayerHandlers.Move
    })
}

function AttackMove:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos 
    self.attack = obj.attack
    self.move = obj.move
end

return AttackMove

