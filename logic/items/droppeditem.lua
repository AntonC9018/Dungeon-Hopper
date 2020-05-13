local Entity = require '@base.entity'
local DroppedItem = class('DroppedItem', Entity)

-- the slot in the inventory
DroppedItem.layer = Layers.dropped

-- apply decorators
local decorate = require('@decorators.decorate')
local Decorators = require "@decorators.decorators"

Decorators.Start(DroppedItem)
decorate(DroppedItem, Decorators.Killable)

-- remove oneself from world on pickup
-- function DroppedItem:beEquipped(entity)
--     self:die()
-- end

function DroppedItem:addItemId(id)
    table.insert(self.state, id)
end

function DroppedItem:setItemId(id)
    self.state = { id }
end

function DroppedItem:getItemIds()
    return self.state
end

return DroppedItem