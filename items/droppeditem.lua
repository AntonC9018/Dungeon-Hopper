local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local DroppedItem = class('DroppedItem', Entity)

-- the slot in the inventory
DroppedItem.layer = Cell.Layers.dropped

-- apply decorators
local decorate = require ("logic.decorators.decorator").decorate
local Decorators = require "logic.decorators.decorators"

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