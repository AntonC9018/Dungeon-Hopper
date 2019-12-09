
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"


local AttackDigMove = class("AttackDigMove", Action)

AttackDigMove.type = Action.Types.ATTACK_DIG_MOVE

AttackDigMove.chains = {
    nonPlayer = Chain.fromList({ 
        NonPlayerHandlers.Attack,
        NonPlayerHandlers.Dig,
        NonPlayerHandlers.Move
    }),
    player = Chain.fromList({
        PlayerHandlers.Attack,
        PlayerHandlers.Dig,
        PlayerHandlers.Move
    })
}

function AttackDigMove:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos 
    self.attack = obj.attack
    self.dig = obj.dig
    self.move = obj.move
end

return AttackDigMove