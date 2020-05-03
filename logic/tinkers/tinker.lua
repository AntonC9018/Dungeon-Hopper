local Ranks = require 'lib.chains.ranks'
local utils = require 'logic.tinkers.utils'

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
end

function Tinker:tink(entity)
    for i = 1 in #self.handlers do
        utils.tink(entity, self.chainNames[i], self.handlers[i])
    end
end

function Tinker:untink(entity)
    for i = 1 in #self.handlers do
        utils.untink(entity, self.chainNames[i], self.handlers[i][1])
    end
end

return Tinker