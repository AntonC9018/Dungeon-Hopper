local utils = require 'logic.retouchers.utils'
local Ranks = require 'lib.chains.ranks'
local ItemTable = require 'items.itemtable'

local equip = {}

-- pick up items
local function pickUp(event)
    local actor = event.actor
    local droppedItem = actor.world.grid:getDroppedAt(actor.pos)
    if droppedItem ~= nil then
        -- droppedItem:beEquipped(actor)
        local id = droppedItem:getItemId()
        local item = ItemTable[id]
        actor:equip(item)
        droppedItem:die()
    end
end

equip.onDisplace = function(entityClass)
    utils.retouch(entityClass, 'displace', { pickUp, Ranks.LOW })
end

return equip