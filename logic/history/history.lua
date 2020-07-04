-- So after such a long pause, the first thing I wish to implement is this
-- Also, I'm going to reimplement tinkers a little + do better job at 
-- keeping track of what tinkers have been applied
local HistoryEvent = require '@history.event'

local History = class('History')

function History:__construct(entity) 
    self.events = {}
    self.entity = entity
end

function History:registerEvent(code)
    table.insert(self.events, HistoryEvent(code, self.entity))
end

function History:getFirstByCode(code)
    for _, event in ipairs(self.events) do
        if event.code == code then
            return event
        end
    end
end

History.was = History.getFirstByCode

function History:getFirstByCodeDuringPhase(code, phase)
    for _, event in ipairs(self.events) do
        if event.code == code and event.phase == phase then
            return event
        end
    end
end

History.wasDuringPhase = History.getFirstByCodeDuringPhase

function History:clear()
    self.events = {}
end

return History