local utils = require '@retouchers.utils'

local noAction = {}


local function doNotAct(event)
    event.actor.didAction = true
end

noAction.ifHit = function(entityClass)
    utils.retouch(entityClass, 'beHit', doNotAct)
end

noAction.ifPushed = function(entityClass)
    utils.retouch(entityClass, 'bePushed', doNotAct)
end


local function preventAction(event)
    for _, t in event.targets do
        t.entity.didAction = true
    end
end

noAction.byAttacking = function(entityClass)
    utils.retouch(entityClass, 'attack', preventAction)
end


return noAction