local utils = {}

utils.retouch = function(entityClass, chainName, handler)
    entityClass.chainTemplate:addHandler(chainName, handler)
end

return utils