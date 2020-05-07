local utils = require 'logic.retouchers.utils'
local Ranks = require 'lib.chains.ranks'

local equip = {}

-- pick up items
local function pickUp(event)
    local actor = event.actor
    local item = actor.world.grid:getDroppedAt(actor.pos)
    if item ~= nil then
        item:beEquipped(actor)
    end
end

equip.onDisplace = function(entityClass)
    utils.retouch(entityClass, 'displace', { pickUp, Ranks.LOW })
end

return equip