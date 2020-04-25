--
-- chain.lua
--
-- Responsibility chain implementation
--
-- These chains are heavily employed in the game logic.
--
-- For example, before applying an attack, the event with the attack
-- passes through several handlers, which can alter it.
-- 
-- They might also stop the propagation of the event. 
-- The propagation never stops completely, though, unless 
-- a stop condition is explicitly specified and, obviously, met.
--
-- The hadlers are just functions
--
-- The event objects are also not specified, but the following
-- construction is going to be used frequently
--
-- {
--      propagate: true / false,
--      + some payload     
-- }
--
-- Very often the checkStopCondition() function is just going to check 
-- the propagation value.
--
-- The handlers are totally allowed to mutate the event object!


-- Class initialization

local Chain = {}

setmetatable(Chain, {
    __call = function (...) return Chain.new(...) end
})

function Chain:new(handlers)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj:construct(handlers)
    return obj
end 

function Chain:construct(handlers)
    self.handlers = handlers or {}
    self.toAdd = {}
    self.toRemove = {}
end


-- The logic

function Chain:addHandler(handler)
    assert(type(handler) == 'function', "Expected handler to be a function, got "..type(handler))
    table.insert(self.toAdd, handler) 
end

function Chain:addHandlers(handlerList)
    for i = 1, #handlerList do
        self:addHandler(handlerList[i]) 
    end
end

function Chain:removeHandler(handler)
    table.insert(self.toRemove, handler)
end

function Chain:cleanUp(handler)
    for i = 1, #self.toRemove do
        for j = 1, #self.handlers do
            if self.handlers[j] == self.toRemove[i] then
                table.remove( self.handlers, j ) 
                break
            end
        end
    end
    self.toRemove = {}
    merge_array(self.handlers, self.toAdd)
    self.toAdd = {}
end

function Chain:pass(propagatingEvent, checkStopCondition)
    self:cleanUp()
    for i = 1, #self.handlers do
        self.handlers[i](propagatingEvent)

        -- if stop condition is specified, check it, and stop
        -- propagation if it is met
        if checkStopCondition ~= nil then
            if checkStopCondition(propagatingEvent) then
                return propagatingEvent
            end
        end
    end
    return propagatingEvent
end

function Chain:__tostring()
    return string.format("Chain(%i)", #self.handlers + #self.toAdd)
end

-- the typical checkStopCondition function is also provided
Chain.checkPropagate = function(event)
    return not event.propagate 
end

Chain.fromList = function(listOfHandlers)
    local chain = Chain()
    chain.handlers = listOfHandlers
    return chain
end

Chain.fromHandler = function(handler)
    local chain = Chain()
    chain:addHandler(handler)
    return chain
end

return Chain