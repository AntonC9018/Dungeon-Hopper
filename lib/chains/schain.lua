local Ranks = require 'lib.chains.ranks'
local Numbers = require 'lib.chains.numbers'

-- The sorted version of chains

-- Class initialization

local SChain = {}

setmetatable(SChain, {
    __call = function (...) return SChain.new(...) end
})

function SChain:new(handlers)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj:construct()    

    if handlers ~= nil then
        obj:addHandlers(handlers)
        obj:sortHandlers()
    end

    return obj
end 

function SChain:construct()
    self.toAdd = {}
    self.toRemove = {}
    self.ranks = Numbers.getRankMap()
    self.handlers = {}
end


-- The logic

function SChain:addHandler(handler)
    if type(handler) == 'function' then
        self:addHandler({ handler, Ranks.MEDIUM })
    else
        assert(type(handler[1]) == 'function', "Expected handler to be a function, got "..type(handler[1]))
        if handler[2] < 6 then
            handler[2], self.ranks[ handler[2] ] = 
                self.ranks[ handler[2] ], self.ranks[ handler[2] ] - 5
        end
        table.insert(self.toAdd, handler)
    end
end

function SChain:addHandlers(handlerList)
    for i = 1, #handlerList do
        self:addHandler(handlerList[i]) 
    end
end

function SChain:removeHandler(handler)
    table.insert(self.toRemove, handler)
end

function SChain:cleanUp()
    for i = 1, #self.toRemove do
        local removed = false
        for j = 1, #self.handlers do
            if self.handlers[j][1] == self.toRemove[i] then
                table.remove( self.handlers, j ) 
                removed = true
                break
            end
        end
        -- the handler might be in the toAdd list
        if not removed then
            for j = 1, #self.toAdd do
                if self.toAdd[j][1] == self.toRemove[i] then
                    table.remove( self.toAdd, j ) 
                    break
                end
            end
        end
    end
    self.toRemove = {}
    table.mergeArray(self.handlers, self.toAdd)

    if #self.toAdd ~= 0 then
        self:sortHandlers()
    end

    self.toAdd = {}    
end

function SChain:sortHandlers()
    table.sort(
        self.handlers,
        function(a, b)
            return a[2] > b[2]
        end
    )
end

function SChain:pass(propagatingEvent, checkStopCondition)
    self:cleanUp()   

    for i = 1, #self.handlers do
        self.handlers[i][1](propagatingEvent)

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

function SChain:__tostring()
    return string.format("SChain(%i)", #self.handlers + #self.toAdd)
end

-- the typical checkStopCondition function is also provided
SChain.checkPropagate = function(event)
    return not event.propagate 
end

SChain.fromList = function(listOfHandlers)
    local chain = SChain()
    chain:addHandlers(listOfHandlers)
    return chain
end

SChain.fromHandler = function(handler)
    local chain = SChain()
    chain:addHandler(handler)
    return chain
end

return SChain