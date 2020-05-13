local utils = require '@decorators.utils'
local Decorator = require '@decorators.decorator'
local Event = require 'lib.chains.event'

local InventoryContainer = class('InventoryContainer')

function InventoryContainer:__construct(size)
    self.size = size
    self.clock = 1
    self.items = {}
    self.excess = {}
end

function InventoryContainer:addItem(item)
    local existingItem = self.items[self.clock]
    if existingItem ~= nil then
        table.insert(self.excess, existingItem)
    end
    self.items[self.clock] = item
    self.clock = self.clock + 1
    if self.clock > self.size then
        self.clock = 1
    end
end

function InventoryContainer:removeExcess()
    local result = self.excess
    self.excess = {}
    return result
end


function InventoryContainer:removeItem(itemToRemove)
    for index, item in ipairs(self.items) do
        if item == itemToRemove then
            self.items[index] = nil
            -- need to shift everything to the left
            for i = index + 1, self.clock do
                self.items[i - 1] = self.items[i]
            end
            -- need to turn the clock back one postion
            self.clock = self.clock - 1
            -- if clock is out, wrap it around
            if self.clock == 0 then
                self.clock = self.size
            end
            return item
        end
    end
end


function InventoryContainer:get(i)
    return self.items[i]
end


local Inventory = class('Inventory', Decorator)

Inventory.Slots = {
    weapon = 1,
    body = 2,
    boots = 3,
    hat = 4,
    ring = 5,
    shovel = 6,
    trinket = 7,
    consumable = 8,
    magic = 9, 
    bag = 10
}
-- Now how do we actually store slot lengths
local SlotsLength = {
    1,
    1,
    1,
    1,
    1,
    1,
    75,
    2,
    2,
    1
}
-- local StatusIndexToName = {}
local numberSlots = #SlotsLength



function Inventory:__construct(actor)
    self.actor = actor
    actor.inventory = self
    self.containers = {}
    for i, size in ipairs(SlotsLength) do
        self.containers[i] = InventoryContainer(size)
    end
end


function Inventory:equip(item)
    local slot = item.slot
    if self.containers[slot] then
        self.containers[slot]:addItem(item)
        item:beEquipped(self.actor)
        printf('A %s has been added to the %i container', class.name(item), slot)
    else
        printf('Inventory doesn\'t have a container of slot %s', slot)
    end
end


function Inventory:unequip(item)
    local slot = item.slot 
    if self.containers[slot] then
        local droppedItem = self.containers[slot]:removeItem(item)
        if droppedItem ~= nil then
            item:beUnequipped(self.actor)
            printf('A %s has been unequipped from the %i container', class.name(item), slot)
        end
    else
        printf('Inventory doesn\'t have a container of slot %s', slot)
    end
end


function Inventory:remove(item)
    local slot = item.slot 
    if self.containers[slot] then
        local droppedItem = self.containers[slot]:removeItem(item)
        if droppedItem ~= nil then
            item:beDestroyed(self.actor)
            printf('A %s has been removed from the %i container', class.name(item), slot)
        end
    else
        printf('Inventory doesn\'t have a container of slot %s', slot)
    end
end


function Inventory:dropExcess()
    local dropped = false
    for _, container in ipairs(self.containers) do
        local excess = container:removeExcess()
        for _, item in ipairs(excess) do
            dropped = true
            item:beUnequipped(self.actor)
        end
    end

    -- the dropped items may have affected the item slots
    -- TODO: improve performance of this
    if dropped then
        self:dropExcess()
    end
end


function Inventory:get(slot)
    return self.containers[slot]
end


function Inventory:findTagged(tag, slot)
    local container = self.containers[slot].items
    for i = 1, #container do
        if container:get(i).tag == tag then
            return container:get(i)
        end
    end
end

return Inventory