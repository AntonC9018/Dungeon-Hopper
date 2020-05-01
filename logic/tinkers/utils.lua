local utils = {}

utils.tinker = function(entity, chainName, handler)
    entityClass.chains[chainName]:addHandler(handler)
end

return utils