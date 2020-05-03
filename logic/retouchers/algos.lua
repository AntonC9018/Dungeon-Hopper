local utils = require 'logic.retouchers.utils'

local algos = {}

local playerAlgo = require 'logic.algos.player'
local generalAlgo = require 'logic.algos.general'

algos.player = function(entityClass)
    utils.retouch(entityClass, 'action', playerAlgo)
end

algos.general = function(entityClass)
    utils.retouch(entityClass, 'action', generalAlgo)
end

return algos