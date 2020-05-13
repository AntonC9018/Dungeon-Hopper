local Entity = require '@base.entity'
local Cell = require 'world.cell'
local DroppedItem = class('DroppedItem', Entity)

-- the slot in the inventory
DroppedItem.layer = Cell.Layers.dropped

-- apply decorators
local decorate = require('@decorators.decorate')
local Decorators = require "@decorators.decorators"

Decorators.Start(DroppedItem)
decorate(DroppedItem, Decorators.Killable)

-- remove oneself from world on pickup
-- function DroppedItem:beEquipped(entity)
--     self:die()
-- end

function DroppedItem:setItemId(id)
    self.state = id
end

function DroppedItem:getItemId()
    return self.state
end

return DroppedItem