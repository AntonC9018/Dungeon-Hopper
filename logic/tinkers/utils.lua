local Ranks = require 'lib.chains.ranks'

local utils = {}

utils.tink = function(entity, chainName, handler)
    entity.chains[chainName]:addHandler(handler)
end

utils.untink = function(entity, chainName, handler)
    entity.chains[chainName]:removeHandler(handler)
end

utils.SelfUntinkingTinker = function(entity, chainName, generator, priority)
    local tinker = {}
    local func = generator(tinker)
    priority = priority ~= nil and priority or Ranks.MEDIUM
    tinker.untink = function()
        utils.untink(entity, chainName, func)
    end
    tinker.tink = function()
        utils.tink(entity, chainName, { func, priority })
    end
    return tinker
end

return utils