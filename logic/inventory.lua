local InventoryContainer = class('InventoryContainer')

function InventoryContainer:__construct(x, y, s, t, inv)
    self.pos = vec(x, y)
    self.size = s
    self.type = t
    self.items = {}
    self.inventory = inv
end

function InventoryContainer:addItem(i)
    table.insert(self.items, i)
    if #self.items > self.size then
        local h = table.remove(self.items, 1)
        self.inventory:drop(h)
    end
end


local Inventory = class('Inventory')


return Inventory