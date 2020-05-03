local utils = require 'logic.retouchers.utils'


local function bump(event)
    local pos, newPos = event.actor.pos, event.newPos
    if 
        newPos.x == pos.x
        and newPos.y == pos.y
    then
        event.actor.world:registerChange(event.actor, Changes.Bump)
    end
end

return function(entityClass)
    utils.retouch(entityClass, 'displace', { bump, Numbers.rankMap[Ranks.MEDIUM] + 1 })
end