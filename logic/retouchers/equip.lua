local utils = require '@retouchers.utils'
local Ranks = require 'lib.chains.ranks'

local equip = {}

-- pick up items
local function pickUp(event)
    local actor = event.actor
    local droppedItem = actor.world.grid:getDroppedAt(actor.pos)
    if droppedItem ~= nil then
        local id = droppedItem:getItemId()
        local item = Items[id]
        actor:equip(item)
        droppedItem:die()
        actor:dropExcess()
    end
end

equip.onDisplace = function(entityClass)
    utils.retouch(entityClass, 'displace', { pickUp, Ranks.LOW })
end

return equip