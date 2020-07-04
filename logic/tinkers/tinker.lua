local Ranks = require 'lib.chains.ranks'
local utils = require '@tinkers.utils'
local generateId = require '@tinkers.id'

local Tinker = class("Tinker")

function Tinker:__construct(tinkElements)
    self.handlers = {}
    self.chainNames = {}
    -- preprocess handlers
    for i, h in ipairs(tinkElements) do
        self.chainNames[i] = h[1]
        self.handlers[i] = 
            type(h[2]) == 'function'
            and { h[2], Ranks.MEDIUM }
            or h[2]
    end

    -- give it a unique id
    -- this is used to mark whether a tinker has been applied to an entity
    -- also, stores use this id to keep their items
    self.id = generateId()
end

function Tinker:tink(entity)

    if entity.tinkerData[self.id] then
        printf("Be careful! The tinker of id %s has been applied more than once", self.id)
    else
        entity.tinkerData[self.id] = true
    end

    for i = 1, #self.handlers do
        utils.tink(entity, self.chainNames[i], self.handlers[i])
    end
end

function Tinker:untink(entity)

    entity.tinkerData[self.id] = nil

    for i = 1, #self.handlers do
        utils.untink(entity, self.chainNames[i], self.handlers[i][1])
    end
end

return Tinker