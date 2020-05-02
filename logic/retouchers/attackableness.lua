local utils = require 'logic.retouchers.utils'
local Attackableness = require 'logic.enums.attackableness'

local attackableness = {}


local function constant(attackableness)
    return function(event)
        event.result = attackableness
    end
end

local functions = {}

for k, v in pairs(Attackableness) do
    functions[v] = constant(v)
end

attackableness.constant = function(entityClass, attackableness)
    utils.retouch(entityClass, 'attackableness', functions[attackableness])
end

return attackableness