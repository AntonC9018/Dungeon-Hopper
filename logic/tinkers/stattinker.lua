local Ranks = require 'lib.chains.ranks'
local utils = require '@tinkers.utils'
local generateId = require '@tinkers.id'

local StatTinker = class("StatTinker")

function StatTinker:__construct(statChanges)
    -- expected are stats of form { { ...args to setStat / addStat }, ... }
    self.threeVarChanges = {}
    self.twoVarChanges = {}
    self.handlers = {}

    for _, s in ipairs(statChanges) do
        if type(s[2]) == 'string' then
            table.insert(self.threeVarChanges, s)
        elseif type(s[2]) == 'function' then
            table.insert(self.handlers, s)
        else 
            table.insert(self.twoVarChanges, s)
        end
    end    

    self.id = generateId()
end

function StatTinker:tink(entity)

    if entity.tinkerData[self.id] == nil then
        entity.tinkerData[self.id] = 1
    end
    entity.tinkerData[self.id] = entity.tinkerData[self.id] + 1

    -- add the indicated amounts
    for _, s in ipairs(self.threeVarChanges) do
        entity.decorators.DynamicStats:addStat(s[1], s[2], s[3])
    end
    for _, s in ipairs(self.twoVarChanges) do
        entity.decorators.DynamicStats:addStat(s[1], s[2])
    end
    for _, s in ipairs(self.handlers) do
        entity.decorators.DynamicStats:addHandler(s[1], s[2])
    end
end

function StatTinker:untink(entity)

    entity.tinkerData[self.id] = entity.tinkerData[self.id] - 1

    -- subtract the indicated amounts
    for _, s in ipairs(self.threeVarChanges) do
        entity.decorators.DynamicStats:addStat(s[1], s[2], -s[3])
    end
    for _, s in ipairs(self.twoVarChanges) do
        entity.decorators.DynamicStats:addStat(s[1], -s[2])
    end
    for _, s in ipairs(self.handlers) do
        entity.decorators.DynamicStats:removeHandler(s[1], s[2])
    end
end

return StatTinker