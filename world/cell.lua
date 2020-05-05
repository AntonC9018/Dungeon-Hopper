-- local Gold = require("environ.gold")

local Cell = class("Cell")

Cell.Layers = {
    floor = 1,
    misc = 2,
    trap = 3,
    gold = 4,
    wall = 5,
    projectile = 6,
    dropped = 7,
    real = 8,
    explosion = 9,
    player = 10 -- this is not actually used in Cell, this is for completeness in Grid
}

function Cell:__construct(pos)
    self.pos = pos
    self.layers = {
        nil, -- the floor layer
        nil, -- misc layer
        nil, -- the trap layer
        nil, -- gold layer
        nil, -- walls layer
        nil, -- projectiles layer
        nil, -- dropped items layer
        nil  -- reals layer
    }
end

function Cell:get(layer)
    return self.layers[layer]
end

function Cell:getFloor()
    return self.layers[Cell.Layers.floor]
end

function Cell:getTrap()
    return self.layers[Cell.Layers.trap]
end

function Cell:getWall()
    return self.layers[Cell.Layers.wall]
end

function Cell:getReal()
    return self.layers[Cell.Layers.real]
end

function Cell:getDropped()
    return self.layers[Cell.Layers.dropped]
end

function Cell:getProjectile()
    return self.layers[Cell.Layers.projectile]
end

function Cell:setFloor(floor)
    self.layers[Cell.Layers.floor] = floor
end

function Cell:setReal(real)
    self.layers[Cell.Layers.real] = real
end

function Cell:setTrap(trap)
    self.layers[Cell.Layers.trap] = trap
end

function Cell:setWall(wall)
    self.layers[Cell.Layers.wall] = wall
end

function Cell:setProjectile(projectile)
    self.layers[Cell.Layers.projectile] = projectile
end

-- The one generic method
function Cell:set(object)
    local layer = object.layer
    if layer == Cell.Layers.player then
        layer = Cell.Layers.real
    end
    local prev = self.layers[layer]
    self.layers[layer] = object
    return prev
end

function Cell:clear(layer)
    if layer == Cell.Layers.player then
        layer = Cell.Layers.real
    end
    local prev = self.layers[layer]
    self.layers[layer] = nil
    return prev
end


function Cell:dropGold(amount)
    local gold = self:getGold()
    if gold == nil then
        gold = Gold(amount)
        self:setGold(gold)
    else
        gold.add(amount)  
    end
end

function Cell:setGold(gold)
    self.layers[Cell.Layers.gold] = gold
end

function Cell:getGold()
    return self.layers[Cell.Layers.gold]
end


return Cell