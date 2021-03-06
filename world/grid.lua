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

function Grid:__construct(w, h)
    -- The grid is a 2d array of such cells.
    self.grid = create(w, h)
    self.width = w
    self.height = h
    -- Lists of game objects at all layers
    self.layers = {}
    -- Lists for various types of game objects at play
    self.reals = {}
    self.players = {}
    self.walls = {}
    self.gold = {}
    self.traps = {}
    self.floors = {}
    self.projectiles = {}
    self.misc = {}
    self.dropped = {}

    self.layers[Cell.Layers.real] = self.reals
    self.layers[Cell.Layers.player] = self.players
    self.layers[Cell.Layers.wall] = self.walls
    self.layers[Cell.Layers.gold] = self.gold
    self.layers[Cell.Layers.trap] = self.traps
    self.layers[Cell.Layers.floor] = self.floors
    self.layers[Cell.Layers.projectile] = self.projectiles
    self.layers[Cell.Layers.misc] = self.misc
    self.layers[Cell.Layers.dropped] = self.dropped

    -- create watcher emitters
    self.watchers = {}
    self.watchers[0] = Emitter()
end

function Grid:checkBound(pos)
    return pos.x > 0 and pos.x <= self.width 
        and pos.y > 0 and pos.y <= self.height
end

-- Watch functionality
function Grid:getWatchCode(pos)
    return string.format('%i-%i', pos.x, pos.y)
end

function Grid:watchOnto(pos, func, count)
    self:watch(pos, 'onto', func, count or 0)
end

function Grid:watchFrom(pos, func, count)
    self:watch(pos, 'from', func, count or 0)
end

function Grid:watch(pos, event, func, count)
    local code = self:getWatchCode(pos)
    local ev =   event..code
    if self.watchers[count] == nil then
        self.watchers[count] = Emitter()
    end
    self.watchers[count]:on(ev, func)
end

function Grid:unwatch(pos, func)
    local code = self:getWatchCode(pos)
    self.watchers[0]:removeListener(code, func)
end

function Grid:resetBeat()
    -- shift the emitters to the left
    for i = 1, #self.watchers do
        self.watchers[i] = self.watchers[i + 1]  
    end
end

function Grid:emitWatchers(pos, event, entity)
    -- emit watchers
    local code = self:getWatchCode(pos)
    local ev =   event..code
    for i = 0, #self.watchers do
        if self.watchers[i] ~= nil then
            self.watchers[i]:emit(ev, entity)
        end
    end
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
    return cell:getReal()
end

function Grid:getWallAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    return cell:getWall()
end

function Grid:getFloorAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    return cell:getFloor()
end

function Grid:getTrapAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    return cell:getTrap()
end

function Grid:getProjectileAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    return cell:getProjectile()
end

function Grid:getDroppedAt(pos)
    local cell = self:getCellAt(pos)
    if cell == nil then
        return nil
    end
    return cell:getDropped()
end

function Grid:getByLayer(layer, pos)
    return self:getCellAt(pos):get(layer)
end

function Grid:getClosestPlayer(pos) 
    if #self.players == 0 then
        return nil
    end

    local minDistance = (pos - self.players[1].pos):magSq()
    local minPlayer = self.players[1]

    for i = 2, #self.players do
        local curDist = (pos - self.players[i].pos):magSq()
        if curDist < minDistance then
            minDistance = curDist
            minPlayer = self.player[i]
        end
    end
    return minPlayer
end

function Grid:getOneFromTopAt(pos)
    local result
    result = self:getRealAt(pos)
    if result ~= nil then return result end
    result = self:getWallAt(pos)
    if result ~= nil then return result end
    result = self:getProjectileAt(pos)
    if result ~= nil then return result end
    result = self:getTrapAt(pos)
    return result
end


function Grid:getAllAt(pos)
    local all = {}

    local cell = self:getCellAt(pos)
    if cell == nil then
        return all
    end

    for i = Cell.Layers.floor, Cell.Layers.real do
        local entity = cell:get(i)
        if entity ~= nil then
            table.insert(all, entity)
        end
    end
    return all
end

-- RESET methods

-- the one generic method
function Grid:reset(entity)
    if entity.dead then
        return
    end
    local cell = self:getCellAt(entity.pos)
    cell:set(entity)
    self:emitWatchers(entity.pos, 'onto', entity)
end

-- function Grid:resetPlayer(player)
--     local cell = self:getCellAt(player.pos)
--     cell:setReal(player)
-- end

-- function Grid:resetReal(real)
--     local cell = self:getCellAt(real.pos)
--     cell:setReal(real)
-- end

-- function Grid:resetTrap(trap)
--     local cell = self:getCellAt(trap.pos)
--     cell:setTrap(trap)
-- end

-- function Grid:resetWall(wall)
--     local cell = self:getCellAt(wall.pos)
--     cell:setWall(wall)
-- end

-- function Grid:resetFloor(floor)
--     local cell = self:getCellAt(floor.pos)
--     cell:setFloor(floor)
-- end

-- function Grid:resetProjectile(projectile)
--     local cell = self:getCellAt(projectile.pos)
--     cell:setProjectile(projectile)
-- end


-- SET methods

-- TODO: yep
function Grid:set(g, pos)
    local cell = self:getCellAt(pos)
    cell:set(g)
    table.insert(self.layers[g.layer], g)
end

function Grid:setPlayerAt(player, pos)
    local cell = self:getCellAt(pos)
    assert(cell ~= nil)
    cell:setReal(player)    
    -- update the reals list
    table.insert(self.reals, player)
    table.insert(self.players, player)
end

-- -- TODO: modify to allow different sizes
-- function Grid:setRealAt(real, pos)    
--     -- assert object takes up just one cell (for now)
--     assert(real.isSized() == false)
--     local cell = self:getCellAt(pos)
--     assert(cell ~= nil)
--     assert(cell:getReal() == nil)
--     cell:setReal(real)    
--     -- assert(cell:getReal() == real)

--     -- update the reals list
--     table.insert(self.reals, real)
--     if real:isPlayer() then
--         table.insert(self.players, real)
--     end
-- end

-- function Grid:setTrapAt(trap, pos)
--     local cell = self:getCellAt(pos)
--     cell:setTrap(trap)
--     table.insert(self.traps, trap)
-- end

-- function Grid:setWallAt(wall, pos)
--     local cell = self:getCellAt(pos)
--     cell:setWall(wall)
--     table.insert(self.walls, wall)
-- end

-- function Grid:setFloorAt(floor, pos)
--     local cell = self:getCellAt(pos)
--     cell:setFloor(floor)
--     table.insert(self.floors, floor)
-- end

-- function Grid:setProjectileAt(projectile, pos)
--     local cell = self:getCellAt(pos)
--     cell:setProjectile(projectile)
--     table.insert(self.projectiles, projectile)
-- end



-- REMOVE methods

-- the one generic method
function Grid:remove(object)
    local cell = self:getCellAt(object.pos)
    if cell:get(object.layer) == object then
        cell:clear(object.layer)
        self:emitWatchers(object.pos, 'from', object)
    end
end

-- -- TODO: modify to allow different sizes
-- function Grid:removeReal(real)
--     -- assert object takes up just one cell (for now)
--     assert(real.isSized() == false)
--     local cell = self:getCellAt(real.pos)
--     assert(cell ~= nil)
--     assert(cell:getReal() == real)
--     cell:setReal(nil)
-- end

-- function Grid:removeTrap(trap)
--     local cell = self:getCellAt(trap.pos)
--     assert(cell ~= nil)
--     assert(cell:getTrap() == trap)
--     cell:setTrap(nil)
-- end

-- function Grid:removeWall(wall)
--     local cell = self:getCellAt(wall.pos)
--     assert(cell ~= nil)
--     assert(cell:getWall() == wall)
--     cell:setWall(nil)
-- end

-- function Grid:removeProjectile(projectile)
--     local cell = self:getCellAt(projectile.pos)
--     assert(cell ~= nil)
--     assert(cell:getProjectile() == projectile)
--     cell:setProjectile(nil)
-- end


-- TODO: SPAWN methods

-- TODO: spawn in the closest cell
function Grid:spawnReal(real)
end


-- TODO: go around the point in a consistent way
function Grid:closest(coord)

end

local function sortByPriority(t)
    table.sort(t, function(a, b) return a.priority > b.priority end)  
end

function Grid:sortAll()
    sortByPriority(self.reals)
    sortByPriority(self.floors)
    sortByPriority(self.walls)
    sortByPriority(self.traps)
    sortByPriority(self.projectiles)
end

-- Sort by priority methods
-- function Grid:sortReals()
--     sortByPriority(self.reals)
-- end

-- function Grid:sortFloors()
--     sortByPriority(self.floors)
-- end

-- function Grid:sortWalls()
--     sortByPriority(self.walls)
-- end

-- function Grid:sortTraps()
--     sortByPriority(self.traps)
-- end

-- function Grid:sortProjectiles()
--     sortByPriority(self.projectiles)
-- end


local function calculateActions(t)
    for i = 1, #t do
        t[i]:calculateAction()
    end
end

function Grid:calculateActionsAll()
    calculateActions(self.reals)
    calculateActions(self.floors)
    calculateActions(self.walls)
    calculateActions(self.traps)
    calculateActions(self.projectiles)
    calculateActions(self.misc)
end

-- function Grid:calculateActionsReals()
--     calculateActions(self.reals)
-- end

-- function Grid:calculateActionsFloors()
--     calculateActions(self.floors)
-- end

-- function Grid:calculateActionsWalls()
--     calculateActions(self.walls)
-- end

-- function Grid:calculateActionsTraps()
--     calculateActions(self.traps)
-- end

-- function Grid:calculateActionsProjectiles()
--     calculateActions(self.projectiles)
-- end

-- function Grid:calculateActionsMisc()
--     calculateActions(self.misc)
-- end

local function tick(t)
    for i = 1, #t do
        if not t[i].dead then
            t[i]:tick()
        end
    end
end

function Grid:tickReals()
    tick(self.reals)
end

function Grid:tickFloors()
    tick(self.floors)
end

function Grid:tickWalls()
    tick(self.walls)
end

function Grid:tickTraps()
    tick(self.traps)
end

function Grid:tickProjectiles()
    tick(self.projectiles)
end

function Grid:tickMisc()
    tick(self.misc)
end

local function filterDead(t)
    for i = #t, 1, -1 do
        -- print(t[i]) -- debug
        if t[i].dead then
            table.remove(t, i)
        end
    end
end

function Grid:filterDeadAll()
    filterDead(self.players)
    filterDead(self.reals)
    filterDead(self.floors)
    filterDead(self.walls)
    filterDead(self.traps)
    filterDead(self.projectiles)
end

-- function Grid:filterDeadPlayers()
--     filterDead(self.players)
-- end

-- function Grid:filterDeadReals()
--     filterDead(self.reals)
-- end

-- function Grid:filterDeadFloors()
--     filterDead(self.floors)
-- end

-- function Grid:filterDeadWalls()
--     filterDead(self.walls)
-- end

-- function Grid:filterDeadTraps()
--     filterDead(self.traps)
-- end

-- function Grid:filterDeadProjectiles()
--     filterDead(self.projectiles)
-- end

function Grid:hasBlockAt(pos)
    local cell = self:getCellAt(pos)
    return 
        cell == nil
        or cell:getReal() ~= nil
        or cell:getWall() ~= nil
end

return Grid