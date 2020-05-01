-- 
-- action.lua
--
-- This file contains the Action class, which is anything an object
-- plans to do or does that may change the game state.

local Action = class("Action")
local NormalChain = require 'lib.chains.chain'

function Action:getChain()
    return self.chain
end

function Action:setDirection(dir)
    self.direction = dir
end

Action.fromHandlers = function(name, handlers)
    local chain = NormalChain()
    if type(handlers) == 'table' then
        chain:addHandlers(handlers)
    else
        chain:addHandler(handlers[1])
    end
    local actionClass = class(name, Action)
    actionClass.chain = chain
    return actionClass
end

return Action