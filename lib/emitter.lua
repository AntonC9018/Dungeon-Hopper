-- I'm just gonna write my own library for events
-- I'm sick of fixing other people's bugs
local Emitter = {}

local pfx_once = '_once_'

setmetatable(Emitter, {
    __call = function (_) return Emitter:new() end
})

function Emitter:new()
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj:construct()

    return obj
end

function Emitter:construct()

    -- first it will have a table of events
    self.events = {}

    -- each of those events is going to be a string
    -- and the value will be the array of listeners
    -- anything else?
    self.events_to_remove = {}
end


function Emitter:on(event, listener)

    if self.events[event] then
        table.insert(self.events[event], listener)

    else
        self.events[event] = { listener }
    end


end


function Emitter:emit(event, ...)

    self:cleanUp()

    if self.events[event] then
        for i = 1, #self.events[event] do
            self.events[event][i](...)
        end
    end

    local once_event = pfx_once..event

    if self.events[once_event] then
        for i = 1, #self.events[once_event] do
            self.events[once_event][i](...)
        end
        self.events[once_event] = nil
    end

    self:cleanUp()

end

function Emitter:cleanUp()

    for key, arr in pairs(self.events_to_remove) do
        for i = 1, #arr do
            for j = 1, #self.events[key] do
                if arr[i] == self.events[key][j] then
                    table.remove(self.events[key], j)
                    break
                end
            end
        end
    end

    self.events_to_remove = {}

end


function Emitter:removeListener(event, listener)

    if self.events_to_remove[event] then
        table.insert(self.events_to_remove[event], listener)
    else
        self.events_to_remove[event] = { listener }
    end

    return false

end



function Emitter:once(event, listener)

    self:on(pfx_once..event, listener)

end


function Emitter:untilTrue(event, listener, finally)

    local function wrapper(...)
        local args = listener(...)
        if args then
            self:removeListener(event, wrapper)
            if finally then finally(args, ...) end
        end
    end

    self:on(event, wrapper)

end


function Emitter:removeAllListeners(event)
    self.events[event] = nil
    self.events[pfx_once..event] = nil
end


return Emitter