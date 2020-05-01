local NormalChain = require 'lib.chains.chain'

local utils = {}

utils.traverseChainFunction = function(chain)
    return function(event)
        chain:pass(event)
    end
end


utils.optionalChain = function(p)
    if p == nil then
        return NormalChain()
    elseif type(p) == 'function' then
        return NormalChain{ p }
    elseif p[1] ~= nil then
        return NormalChain(p)
    end
    return p
end

return utils