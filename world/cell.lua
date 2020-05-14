-- local Gold = require("environ.gold")

local Cell = class("Cell")

local Layers = {
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

Cell.Layers = Layers

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
    return self.layers[Layers.floor]
end

function Cell:getTrap()
    return self.layers[Layers.trap]
end

function Cell:getWall()
    return self.layers[Layers.wall]
end

function Cell:getReal()
    return self.layers[Layers.real]
end

function Cell:getDropped()
    return self.layers[Layers.dropped]
end

function Cell:getProjectile()
    return self.layers[Layers.projectile]
end

function Cell:setFloor(floor)
    self.layers[Layers.floor] = floor
end

function Cell:setReal(real)
    self.layers[Layers.real] = real
end

function Cell:setTrap(trap)
    self.layers[Layers.trap] = trap
end

function Cell:setWall(wall)
    self.layers[Layers.wall] = wall
end

function Cell:setProjectile(projectile)
    self.layers[Layers.projectile] = projectile
end

-- The one generic method
function Cell:set(object)
    local layer = object.layer

    if layer == Layers.player then
        layer = Layers.real
    end
    self.layers[layer] = object
end

function Cell:clear(layer)
    if layer == Layers.player then
        layer = Layers.real
    end
    self.layers[layer] = nil
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
    self.layers[Layers.gold] = gold
end

function Cell:getGold()
    return self.layers[Layers.gold]
end


return Cell