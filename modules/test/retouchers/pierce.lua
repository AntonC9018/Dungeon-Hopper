local Ranks = require 'lib.chains.ranks'
local utils = require 'logic.retouchers.utils'

local pierce = {}

-- TODO: store functions that have already been used for optimization
local function pierceHandler(DAMAGE, PIERCE)
    return function (event)
        if event.action.attack.damage >= DAMAGE then
            event.resistance:set('pierce', PIERCE)
        end
    end
end

pierce.removeOnGreatDamage = function(entityClass)
    retouch(entityClass, 'defence', pierceHandler(3, 0))
end

pierce.setIfDamageAbove = function(entityClass, damageThreshold, reducedPierce)
    retouch(entityClass, 'defence', pierceHandler(damageThreshold, reducedPierce))
end

pierce.removeIfDamageAbove = function(entityClass, damageThreshold)
    retouch(entityClass, 'defence', pierceHandler(damageThreshold, 0))
end

return pierce