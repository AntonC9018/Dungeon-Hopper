local Changes = require 'render.changes'
local utils = require '@retouchers.utils'


local function bump(event)
    local pos, newPos = event.actor.pos, event.newPos
    if 
        newPos.x == pos.x
        and newPos.y == pos.y
    then
        event.actor:registerEvent(Changes.Bump)
    end
end

return function(entityClass)
    utils.retouch(entityClass, 'displace', { bump, RankNumbers.rankMap[Ranks.MEDIUM] + 1 })
end