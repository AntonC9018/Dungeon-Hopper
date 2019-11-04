local InventoryContainer = class('InventoryContainer')

function InventoryContainer:__construct(params)
    self.anchor = params.anchor
    self.size = params.size
    self.name = params.name
    self.inv = params.inventory
    self.items = {}
end

function InventoryContainer:addItem(i)
    table.insert(self.items, i)
    if #self.items > self.size then
        local h = table.remove(self.items, 1)
        return h
    end
    return false
end

function InventoryContainer:get(i)
    return self.items[i]
end


local Inventory = class('Inventory')


function Inventory:__construct()
    -- the container for containers
    self.c = {}
    self.c.weapon =      InventoryContainer({ anchor = Vec(0, 0), size = 1, name = 'weapon', inv = self })
    self.c.body =        InventoryContainer({ anchor = Vec(0, 0), size = 1, name = 'body', inv = self })
    self.c.boots =       InventoryContainer({ anchor = Vec(0, 0), size = 1, name = 'boots', inv = self })
    self.c.hat =         InventoryContainer({ anchor = Vec(0, 0), size = 1, name = 'hat', inv = self })
    self.c.ring =        InventoryContainer({ anchor = Vec(0, 0), size = 1, name = 'ring', inv = self })
    self.c.shovel =      InventoryContainer({ anchor = Vec(0, 0), size = 1, name = 'shovel', inv = self })
    self.c.trinket =     InventoryContainer({ anchor = Vec(0, 0), size = 75, name = 'trinket', inv = self })
    self.c.consumable =  InventoryContainer({ anchor = Vec(0, 0), size = 2, name = 'consumable', inv = self })
    self.c.magic =       InventoryContainer({ anchor = Vec(0, 0), size = 2, name = 'magic', inv = self })
    self.c.bag =         InventoryContainer({ anchor = Vec(0, 0), size = 1, name = 'bag', inv = self })
    self.to_drop = {}
end


function Inventory:equip(i)
    local type = i.item_slot
    if self.c[type] then
        local excess = self.c[type]:addItem(i)
        print(string.format('A %s has been added to the %s container', class.name(i), type))
        -- TODO: emit event

        if excess then
            merge_array(self.to_drop, excess)
        end
    else
        print(string.format('Inventory doesn\'t have a container of type %s', type))
    end
end



function Inventory:drop(p)
    local x, y = p.pos.x, p.pos.y
    local cell = p.world.grid[x][y]
    merge_array(cell.items, self.to_drop)
    self.to_drop = {}
end

-- ?
function Inventory:activateAll(p, t)
    for _, item_container in pairs(self.c) do
        for i = 1, #item_container do
            item_container:get(i):activate(p, t)
        end
    end
end


function Inventory:get(type)
    return self.c[type]
end


function Inventory:findTagged(tag, type)
    local item_container = self.c[type]
    for i = 1, #item_container do
        if item_container:get(i).tag == tag then
            return item_container:get(i)
        end
    end
    return false
end

return Inventory