local Grid = require "world.grid"

local World = class("World")
local Changes = require 'render.changes'
local DroppedItem = require '@items.droppeditem'

function World:__construct(w, h)
    self.grid = Grid(w or 0, h or 0)
    self.changes = {{}}
    self.pools = {}
    self.phase = 1
end


function World:setRenderer(renderer)
    self.renderer = renderer
end

-- player and entity creation
function World:createPlayer(Player, pos)
    local player = Player()
    player:init(pos, self)
    self.grid:setPlayerAt(player, pos)
    self.renderer:addRenderEntity(player)
    self.renderer:setAsPlayer(player.id)
    return player
end

function World:createFloors(Tile)
    for i = 1, #self.grid.grid do
        for j = 1, #self.grid.grid[1] do
            self:create( Tile, Vec(i, j) )
        end
    end
end

function World:createDroppedItem(id, pos)
    -- if exists, take the item and add it an id
    local droppedItem = self.grid:getDroppedAt(pos)
    if droppedItem ~= nil then
        droppedItem:addItemId(id)
        -- TODO: signal the rederer to draw a couple of states at once
        return droppedItem
    end
    -- otherwise, create one
    droppedItem = DroppedItem()
    droppedItem:init(pos, self)
    droppedItem:setItemId(id)
    self.grid:set(droppedItem, pos)
    self.renderer:addRenderEntity(droppedItem)
    return droppedItem
end

function World:create(Entity, pos)
    local entity = Entity()
    entity:init(pos, self)
    self.grid:set(entity, pos)
    self.renderer:addRenderEntity(entity)
    return entity
end

--- Convert user input to an action and set it
-- as the action of one of the players. 
-- returns true if the substitution was successful
-- and false otherwise
function World:setPlayerActions(direction, playerIndex)
    local player = self.grid.players[playerIndex]

    if 
        player ~= nil 
        and player.nextAction == nil 
    then
        player:generateAction(direction)
        return true
    end

    return false
end

--- This fuction would check if player actions have been set
-- and do the game loop if they have
function World:gameLoopIfSet()
    local players = self.grid.players
    for i = 1, #players do
        if players[i].nextAction == nil then
            return false
        end
    end
    self:gameLoop()
    return true
end


function World:gameLoop()
    -- sort all game objects by prority
    self:sortByPriority()
    
    -- execute player actions 
    self:executePlayerActions()
    self:advancePhase()

    self:calculateActions()

    -- execute misc stuff, like bombs
    self:activateMisc()
    self.grid:tickMisc()
    self:advancePhase()

    -- execute reals' actions
    self:activateReals()
    self.grid:tickReals()
    self:advancePhase()    

    -- execute projectile actions
    self:activateProjectiles()
    self.grid:tickProjectiles()
    self:advancePhase()

    -- activate floor hazards
    self:activateFloors()
    self.grid:tickFloors()
    self:advancePhase()

    -- activate traps
    self:activateTraps()
    self.grid:tickTraps()
    self:advancePhase()

    -- update render states for all objects 
    self:updateRenderStates()

    -- filter out dead things
    self:filterDead()
    
    -- reset stored actions in objects
    -- reset the phase to 0
    self:reset()
end


function World:reset()
    self:resetPhase()
    -- set objects' actions to the None action
    self:resetObjects()
    self.grid:resetBeat()
end


function World:resetPhase()
    self.phase = 1
end


function World:resetObjects()
    -- for now, just reset the reals and traps
    for i, real in ipairs(self.grid.reals) do        
        real.didAction = false
        real.doingAction = false
        real.nextAction = nil
        real.enclosingEvent = nil
    end
    for i, real in ipairs(self.grid.traps) do        
        real.didAction = false
        real.doingAction = false
        real.nextAction = nil
        real.enclosingEvent = nil
    end
    for i, real in ipairs(self.grid.floors) do        
        real.didAction = false
        real.doingAction = false
        real.nextAction = nil
        real.enclosingEvent = nil
    end
    for i, real in ipairs(self.grid.misc) do        
        real.didAction = false
        real.doingAction = false
        real.nextAction = nil
        real.enclosingEvent = nil
    end
    for i, real in ipairs(self.grid.projectiles) do        
        real.didAction = false
        real.doingAction = false
        real.nextAction = nil
        real.enclosingEvent = nil
    end
end


function World:sortByPriority()
    -- sort everything in grid by priority
    self.grid:sortAll()
end


function World:advancePhase()
    self.phase = self.phase + 1
    self.changes[self.phase] = {}
end


-- NOTE: this should select an action (Attack, Move etc)
-- and set it as the nextAction at that object
-- it should not care much about direction
-- These functions should not be used to tick internal state,
-- that is, e.g. the sequence step. The thing that ticks stuff 
-- is the tick() method
function World:calculateActions()
    self.grid:calculateActionsAll()
end


function World:executePlayerActions()
    for i = 1, #self.grid.players do
        self.grid.players[i]:executeAction()
    end
end

-- TODO: refactor into methods on grid
function World:activateMisc()
    for i = 1, #self.grid.misc do
        if not self.grid.misc[i].didAction then
            self.grid.misc[i]:executeAction()
        end
    end
end


function World:activateReals()
    for i = 1, #self.grid.reals do
        if not self.grid.reals[i].didAction then
            -- printf("%s starts doing action", class.name(self.grid.reals[i])) -- debug
            self.grid.reals[i]:executeAction()
            -- printf("%s ended action", class.name(self.grid.reals[i])) -- debug
        end
    end
end


function World:activateFloors()
    for i = 1, #self.grid.floors do
        if not self.grid.floors[i].didAction then
            -- printf("%s starts doing action", class.name(self.grid.reals[i])) -- debug
            self.grid.floors[i]:executeAction()
            -- printf("%s ended action", class.name(self.grid.reals[i])) -- debug
        end
    end
end


function World:activateTraps()
    for i = 1, #self.grid.traps do
        if not self.grid.traps[i].didAction then
            -- printf("%s starts doing action", class.name(self.grid.reals[i])) -- debug
            self.grid.traps[i]:executeAction()
            -- printf("%s ended action", class.name(self.grid.reals[i])) -- debug
        end
    end
end


function World:activateProjectiles()
    for i = 1, #self.grid.projectiles do
        if not self.grid.projectiles[i].didAction then
            -- printf("%s starts doing action", class.name(self.grid.reals[i])) -- debug
            self.grid.projectiles[i]:executeAction()
            -- printf("%s ended action", class.name(self.grid.reals[i])) -- debug
        end
    end
end


function World:filterDead() 
    self.grid:filterDeadAll() 
end


function World:removeDead(entity)
    self.grid:remove(entity)
end


function World:updateRenderStates()

    -- print(ins(self.changes, {depth = 2})) -- debug
    
    if self.renderer ~= nil then
        self.renderer:pushChanges(self.changes)
        self.changes = {{}}
    end
end


function World:registerChange(obj, code)
    local change = {
        id = obj.id,
        state = obj.state,
        pos = obj.pos,
        orientation = obj.orientation,
        event = code
    }
    table.insert(self.changes[self.phase], change)
end


local Pools = require 'game.pools'

function World:usePool(str, pool)
    Pools.setPoolInListByName(str, pool, self.pools)
end

function World:drawFromPool(poolId)
    local pool = Pools.drawSubpool(poolId, self.pools)
    return pool:getRandom()
end

local Types = require 'world.generation.types'
local Cell = require 'world.cell'

function World:materializeGenerator(generator, Tile, wallSubpoolId, enemySubpoolId)
    self.grid.grid = generator.grid
    self.grid.width = generator.width
    self.grid.height = generator.height

    for i = 1, generator.width do
        for j = 1, generator.height do
            local cell = generator.grid[i][j]
            if cell ~= nil then
                local vec = Vec(i, j)
                if cell.type == Types.TILE or cell.type == Types.HALLWAY then
                    generator.grid[i][j] = Cell(vec)
                    self:create(Tile, vec)
                elseif cell.type == Types.WALL then
                    generator.grid[i][j] = Cell(vec)
                    self:create(Tile, vec)
                    local wallClass = Entities[self:drawFromPool(wallSubpoolId)]
                    self:create(wallClass, vec)
                elseif cell.type == Types.ENEMY then
                    generator.grid[i][j] = Cell(vec)
                    self:create(Tile, vec)
                    local enemyClass = Entities[self:drawFromPool(enemySubpoolId)]
                    self:create(enemyClass, vec)
                else
                    generator.grid[i][j] = nil
                end
            end
        end
    end

    local start = generator.rooms[1] 
    local w = (start.w - 1) / 2
    local h = (start.h - 1) / 2
    return Vec(start.x, start.y) + Vec(math.round(w), math.round(h))
end

return World