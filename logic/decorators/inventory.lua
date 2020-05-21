local utils = require '@decorators.utils'
local Decorator = require '@decorators.decorator'
local Event = require 'lib.chains.event'
local CyclicBuffer = require 'lib.cyclicbuf'


local Inventory = class('Inventory', Decorator)

-- TODO: use different buffer types 
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
        self.containers[i] = CyclicBuffer(size)
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