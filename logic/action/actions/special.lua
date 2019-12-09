
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"

local Special = class("SpecialAction", Action)

Special.type = Action.Types.SPECIAL

Special.chains = {
    nonPlayer = Chain.fromList({ 
        NonPlayerHandlers.Special,
    }),
    player = Chain.fromList({
        PlayerHandlers.Special,
    })
}

function Special:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos
    self.special = obj.special -- TODO: figure what this should be
    self.type = Action.Types.SPECIAL
end

return Special
