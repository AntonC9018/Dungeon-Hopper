-- just an item that gives +1 attack
local Item = require 'items.item'


local tinker = require('modules.test.tinkers.damage')(1)

local testItem = Item(tinker)
testItem.slot = 1

return testItem