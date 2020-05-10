local utils = require 'logic.retouchers.utils'

local algos = {}

local simpleAlgo = require 'logic.algos.simple'
local generalAlgo = require 'logic.algos.general'

algos.simple = function(entityClass)
    utils.retouch(entityClass, 'action', simpleAlgo)
end

algos.general = function(entityClass)
    utils.retouch(entityClass, 'action', generalAlgo)
end

return algos