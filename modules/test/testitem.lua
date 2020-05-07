-- just an item that gives +1 attack
local StatTinker = require 'logic.tinkers.stattinker'
local Item = require 'items.item'
local DroppedItem = require 'items.droppeditem'
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes

local DroppedTestItem = class("DroppedTestItem", DroppedItem)

local tinker = StatTinker({
    { StatTypes.Attack, 'damage', 1 }
})

local TestItem = Item(DroppedTestItem, tinker)
TestItem.slot = 1
DroppedTestItem.item = TestItem

return DroppedTestItem