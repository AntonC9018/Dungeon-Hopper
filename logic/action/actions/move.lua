
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"


local Move = class("MoveAction", Action)

Move.type = Action.Types.MOVE

Move.chains = {
    nonPlayer = Chain.fromList({ 
        NonPlayerHandlers.Move
    }),
    player = Chain.fromList({
        PlayerHandlers.Move
    })
}

function Move:__construct(obj)
    self.direction = obj.direction 
    self.type = Action.Types.MOVE
end

return Move