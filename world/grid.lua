--
-- self.grid.lua
--
-- This file includes helper methods for storing and accessing the board state,
-- that is, entities, walls, traps so on
--
-- The essential storage structure is a cell:
local Cell = require("world.cell")
--
-- This file also contains a whole list of entities, 
-- the it loops through e.g. sending end beat events
local function create(width, height, func) 
    local g = {}
    
    for i = 1, width do
        g[i] = {}
        for j = 1, height do
            local cell = Cell(Vec(i, j))
            if func ~= nil then 
                g[i][j] = func(cell)
            else
                g[i][j] = cell
            end
        end
    end

    return g
end


local Grid = class("Grid")

function Grid:__construct()
    -- The grid is a 2d array of such cells.
    self.grid = {}
    -- Lists of game objects at all layers
    self.layers = {{},{},{},{},{},{},{},{}}
    -- Lists for various types of game objects at play
    self.reals = {}
    self.players = {}
    self.walls = {}
    self.gold = {}
    self.traps = {}
    self.floors = {}
    self.projectiles = {}

    self.layers[Cell.Layers.real] = self.reals
    self.layers[Cell.Layers.player] = self.players
    self.layers[Cell.Layers.wall] = self.walls
    self.layers[Cell.Layers.gold] = self.gold
    self.layers[Cell.Layers.trap] = self.traps
    self.layers[Cell.Layers.floor] = self.floors
    self.layers[Cell.Layers.projectile] = self.projectiles
end

function Grid:checkBound(pos)
    return pos.x > 0 and pos.x <= #self.grid 
        or pos.y > 0 and pos.y <= #self.grid[1]
end

-- Some helper functions for working with the grid
-- There are several types of methods:
--      1. GET. This is for getting contents of a cell or a cell itself
--      2. RESET. This is for setting a thing in grid based on its coordinates
--      3. SET. Place a thing at a particular coordinate. It also adds those things to the internal lists
--      4. REMOVE. Delete a thing off a cell for some time. The objects remain in lists
--                 The only way to remove things from internal lists is for an object to become dead.
--      5. SPAWN. This is useful when you don't care about the exact location 
--                of the object you want to add to the grid. You give the function
--                a coordinate, and it places the object to the nearest unoccupied spot
--      6. For Attacking
--      7. For Explosions 

-- GET methods

function Grid:getCellAt(pos)
    if self:checkBound(pos) then
        return self.grid[pos.x][pos.y]
    end
    return nil
end

function Grid:getOrthogonalCellsAt(pos)
    local toCheck = {
        pos + Vec(1, 0),
        pos + Vec(0, 1),
        pos + Vec(-1, 0),
        pos + Vec(0, -1)
    }
    local result = {}
    for i = 1, #toCheck do
        local cell = self:getCellAt(toCheck[i])
        if cell ~= nil then
            table.insert(result, cell)
        end 
    end
    return result
end

function Grid:getAdjacentCellsAt(pos)
    local toCheck = {        
        pos + Vec(1, 0),
        pos + Vec(1, 1),
        pos + Vec(0, 1),
        pos + Vec(-1, 1),
        pos + Vec(-1, 0),
        pos + Vec(-1, -1),
        pos + Vec(0, -1),
        pos + Vec(1, -1)
    }
    local result = {}
    for i = 1, #toCheck do
        local cell = self:getCellAt(toCheck[i])
        if cell ~= nil then
            table.insert(result, cell)
        end 
    end
    return result
end

function Grid:getDiagonalCellsAt(pos)
    local toCheck = {
        pos + Vec(1, 1),
        pos + Vec(-1, 1),
        pos + Vec(-1, -1),
        pos + Vec(1, -1)
    }
    local result = {}
    for i = 1, #toCheck do
        local cell = self:getCellAt(toCheck[i])
        if cell ~= nil then
            table.insert(result, cell)
        end 
    end
    return result
end

function Grid:getPlayerAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    local real = cell:getReal()
    if real ~= nil and real:isPlayer() then
        return real     
    end
    return nil
end

function Grid:getNonPlayerRealAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    local real = cell:getReal()
    if real ~= nil and not real:isPlayer() then
        return real     
    end
    return nil
end

function Grid:getRealAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    local real = cell:getReal()
    return real    
end

function Grid:getFloorAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    local floor = cell:getFloor()
    return floor   
end

function Grid:getTrapAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    local trap = cell:getTrap()
    return trap
end

function Grid:getProjectileAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    local trap = cell:getProjectile()
    return trap
end

function Grid:getByTypeAt(type, pos)
    local cell = self:getCellAt(pos)
    assert(cell.layers[Cell.Layers.type] ~= nil)
    return cell.layers[Cell.Layers.type][0]
end

function Grid:getByLayer(layer, pos)
    local cell = self:getCellAt(pos)
    assert(cell.layers[layer] ~= nil)
    return cell.layers[layer][0]
end


-- RESET methods

function Grid:resetPlayer(player)
    local cell = self:getCellAt(player.pos)
    cell:setReal(player)
end

function Grid:resetReal(real)
    local cell = self:getCellAt(real.pos)
    cell:setReal(real)
end

function Grid:resetTrap(trap)
    local cell = self:getCellAt(trap.pos)
    cell:setTrap(trap)
end

function Grid:resetWall(wall)
    local cell = self:getCellAt(wall.pos)
    cell:setWall(wall)
end

function Grid:resetFloor(floor)
    local cell = self:getCellAt(floor.pos)
    cell:setFloor(floor)
end

function Grid:resetProjectile(projectile)
    local cell = self:getCellAt(projectile.pos)
    cell:setProjectile(projectile)
end


-- SET methods

function Grid:setPlayerAt(player, pos)
    local cell = self:getCellAt(pos)
    assert(cell ~= nil)
    cell:setReal(player)    
    -- update the reals list
    table.insert(self.reals, player)
    table.insert(self.players, player)
end

-- TODO: modify to allow different sizes
function Grid:setRealAt(real, pos)    
    -- assert object takes up just one cell (for now)
    assert(real.isSized() == false)
    local cell = self:getCellAt(pos)
    assert(cell ~= nil)
    assert(cell:getReal() == nil)
    cell:setReal(real)    
    -- update the reals list
    table.insert(self.reals, real)
    if real:isPlayer() then
        table.insert(self.players, real)
    end
end

function Grid:setTrapAt(trap, pos)
    local cell = self:getCellAt(pos)
    cell:setTrap(trap)
    table.insert(self.traps, trap)
end

function Grid:setWallAt(wall, pos)
    local cell = self:getCellAt(pos)
    cell:setWall(wall)
    table.insert(self.walls, wall)
end

function Grid:setFloorAt(floor, pos)
    local cell = self:getCellAt(pos)
    cell:setFloor(floor)
    table.insert(self.floors, floor)
end

function Grid:setProjectileAt(projectile, pos)
    local cell = self:getCellAt(pos)
    cell:setProjectile(projectile)
    table.insert(self.projectiles, projectile)
end



-- REMOVE methods

-- TODO: modify to allow different sizes
function Grid:removeReal(real)
    -- assert object takes up just one cell (for now)
    assert(real.isSized() == false)
    local cell = self:getCellAt(real.pos)
    assert(cell ~= nil)
    assert(cell:getReal() == real)
    cell:setReal(nil)
end

function Grid:removeTrap(trap)
    local cell = self:getCellAt(trap.pos)
    assert(cell ~= nil)
    assert(cell:getTrap() == trap)
    cell:setTrap(nil)
end

function Grid:removeWall(wall)
    local cell = self:getCellAt(wall.pos)
    assert(cell ~= nil)
    assert(cell:getWall() == wall)
    cell:setWall(nil)
end

function Grid:removeProjectile(projectile)
    local cell = self:getCellAt(projectile.pos)
    assert(cell ~= nil)
    assert(cell:getProjectile() == projectile)
    cell:setProjectile(nil)
end


-- TODO: SPAWN methods

-- TODO: spawn in the closest cell
function Grid:spawnReal(real)
end
