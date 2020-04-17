
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

return AttackDigMove