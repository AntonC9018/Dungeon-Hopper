local Ranks = require 'lib.chains.ranks'
local utils = require 'logic.tinkers.utils'

local StatTinker = class("StatTinker")

function StatTinker:__construct(statChanges)
    -- expected are stats of form { { ...args to setStat / addStat }, ... }
    self.threeVarChanges = {}
    self.twoVarChanges = {}
    self.handlers = {}

    for _, s in statChanges do
        if type(s[2]) == 'string' then
            table.insert(self.threeVarChanges, s)
        elseif type(s[2] == 'function') then
            table.insert(self.twoVarChanges, s)
        else 
            table.insert(self.handlers, s)
        end
    end
end

function StatTinker:tink(entity)
    -- add the indicated amounts
    for _, s in self.threeVarChanges do
        entity:addStat(s[1], s[2], s[3])
    end
    for _, s in self.twoVarChanges do
        entity:addStat(s[1], s[2])
    end
    for _, s in self.handlers do
        entity:addHandler(s[1], s[2])
    end
end

function StatTinker:untink(entity)
    -- subtract the indicated amounts
    for _, s in self.threeVarChanges do
        entity:addStat(s[1], s[2], -s[3])
    end
    for _, s in self.twoVarChanges do
        entity:addStat(s[1], -s[2])
    end
    for _, s in self.handlers do
        entity:removeHandler(s[1], s[2])
    end
end

return StatTinker