
local NonPlayerHandlers = require "logic.action.handlers.nonplayer"
local PlayerHandlers = require "logic.action.handlers.player"
local Action = require "logic.action"
local Chain = require "lib.chains.chain"

local Special = class("SpecialAction", Action)

Special.type = Action.Types.SPECIAL

-- Special is the Action you provide your custom chains to

function Special:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos
    self.special = obj.special -- TODO: figure what this should be
    self.type = Action.Types.SPECIAL
end

-- override get chains methods
-- chain is assumed to have been provided to the class definition
-- of the new action, that would override this 'abstract' Special Action
-- So if this class (Special) were to be written in e.g. C#, it would've been abstract
function Special:getPlayerChain()
    return self.chain
end

function Special:getNonPlayerChain()
    return self.chain
end


return Special
