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
    player = 9 -- this is not actually used in Cell, this is for completeness in Grid
}

function Cell:__construct(pos)
    self.pos = pos
    self.layers = {
        {}, -- the floor layer
        {}, -- misc layer
        {}, -- the trap layer
        {}, -- gold layer
        {}, -- walls layer
        {}, -- projectiles layer
        {}, -- dropped items layer
        {}  -- reals layer
    }
end


function Cell:getFloor()
    return self.layers[Cell.Layers.floor][1]
end

function Cell:getTrap()
    return self.layers[Cell.Layers.trap][1]
end

function Cell:getWall()
    return self.layers[Cell.Layers.wall][1]
end

function Cell:getReal()
    return self.layers[Cell.Layers.real][1]
end

function Cell:getDropped()
    return self.layers[Cell.Layers.dropped][1]
end

function Cell:getProjectile()
    return self.layers[Cell.Layers.projectile][1]
end

function Cell:setFloor(floor)
    local prev = self.layers[Cell.Layers.floor]
    self.layers[Cell.Layers.floor] = { floor }
    return prev
end

function Cell:setReal(real)
    local prev = self.layers[Cell.Layers.real]
    self.layers[Cell.Layers.real] = { real }
    return prev
end

function Cell:setTrap(trap)
    local prev = self.layers[Cell.Layers.trap]
    self.layers[Cell.Layers.traps] = { trap }
    return prev
end

function Cell:setWall(wall)
    local prev = self.layers[Cell.Layers.wall]
    self.layers[Cell.Layers.wall] = { wall }
    return prev
end

function Cell:setProjectile(projectile)
    local prev = self.layers[Cell.Layers.projectile]
    self.layers[Cell.Layers.projectile] = { projectile }
    return prev
end

-- The one generic method
function Cell:set(object)
    local prev = self.layers[object.layer]
    self.layers[object.layer] = { object }
    return prev
end

function Cell:clear(layer)
    local prev = self.layers[layer]
    self.layers[layer] = { }
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
    local prev = self.gold
    self.gold = { gold }
    return prev
end

function Cell:getGold()
    return self.gold[0]
end


return Cell