-- just an item that gives +1 attack
local tinker = require('modules.test.tinkers.damage')(1)

local testItem = Item(tinker)
testItem.slot = InventorySlots.trinket

return testItem