-- 
-- action.lua
--
-- This file contains the Action class, which is anything an object
-- plans to do or does that may change the game state.

local Action = class("Action")

function Action:getChain()
    return self.chain
end

function Action:setDirection(dir)
    self.direction = dir
end

Action.fromHandlers = function(name, handlers, getMovs)
    local chain = Chain()
    chain.handlers = handlers
    local actionClass = class(name, Action)
    actionClass.chain = chain
    actionClass.getMovs = getMovs
    return actionClass
end

return Action