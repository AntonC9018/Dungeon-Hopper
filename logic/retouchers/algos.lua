local utils = require '@retouchers.utils'

local algos = {}

local simpleAlgo = require '@algos.simple'
local generalAlgo = require '@algos.general'

algos.simple = function(entityClass)
    utils.retouch(entityClass, 'action', simpleAlgo)
end

algos.general = function(entityClass)
    utils.retouch(entityClass, 'action', generalAlgo)
end

return algos