local Ranks = require 'lib.chains.ranks'

local utils = {}

utils.tink = function(entity, chainName, handler)
    entityClass.chains[chainName]:addHandler(handler)
end

utils.untink = function(entity, chainName, handler)
    entityClass.chains[chainName]:removeHandler(handler)
end

utils.SelfDetachingTinker = function(entity, chainName, generator, priority)
    local tinker = {}
    local func = generator(tinker)
    priority = priority ~= nil and priority or Ranks.MEDIUM
    tinker.detach = function()
        utils.untinker(entity, chainName, func)
    end
    tinker.apply = function()
        utils.tinker(entity, chainName, { func, priority })
    end
    return tinker
end

local Tinker = class("Tinker")

function Tinker:__construct(handlerDescription)
    self.handlers = {}
    self.chainNames = {}
    -- preprocess handlers
    for i, h in ipairs(handlerDescription) do
        self.chainNames[i] = h[1]
        self.handlers[i] = 
            type(h[2]) == 'function'
            and { h[2], Ranks.MEDIUM }
            or h[2]
    end
end

function Tinker:attach(entity)
    for i = 1 in #self.handlers do
        utils.tinker(entity, self.chainNames[i], self.handlers[i])
    end
end

function Tinker:detach(entity)
    for i = 1 in #self.handlers do
        utils.untinker(entity, self.chainNames[i], self.handlers[i][1])
    end
end


local StatTinker = class("StatTinker")


function StatTinker:__construct(stats)
    -- expected are stats of form { { ...args to setStat / addStat }, ... }
    self.stats = stats
end

function StatTinker:attach(entity)
    -- add the indicated amounts
    for _, s in self.stats do
        entity:addStat(table.unpack(s))
    end
end

function StatTinker:detach(entity)
    -- subtract the indicated amounts
    for _, s in self.stats do
        if type(s[2]) == 'string' then
            entity:addStat(s[1], s[2], -s[3])
        else
            entity:addStat(s[1], -s[2])
        end
    end
end

utils.StatTinker = StatTinker
utils.Tinker = Tinker

return utils