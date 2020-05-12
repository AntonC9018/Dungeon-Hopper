
local ItemTable = require 'items.itemtable'

-- register all existing items for now
local spear = require 'modules.test.items.spear'
local testitem = require 'modules.test.items.testitem'
local shield = require 'modules.test.items.shield'
local shell = require 'modules.test.items.shell'

ItemTable.registerItem(spear)
ItemTable.registerItem(testitem)
ItemTable.registerItem(shield)
ItemTable.registerItem(shell)

local items = {}
for i, _ in ipairs(ItemTable) do
    items[i] = { i, 1, 1 }
end

local config = {
    { { spear.id, shield.id, shell.id }        
    },
    { { testitem.id }
    }
}

return {
    items = items, 
    config = config
}