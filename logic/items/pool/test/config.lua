-- register all existing items for now
local spear = Mods.Test.Items.spear
local testitem = Mods.Test.Items.testitem
local shield = Mods.Test.Items.shield
local shell = Mods.Test.Items.shell

local items = {}
for i, _ in ipairs(Items) do
    items[i] = { i, 1, 1 }
end

local config = {
    { ids = { spear.id, shield.id, shell.id }        
    },
    { ids = { testitem.id }
    }
}

return {
    items = items, 
    config = config
}