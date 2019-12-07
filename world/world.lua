local Grid = require("world.grid")

local World = class("World")


function World:__construct()
    self.grid = Grid(25, 25)
    self.orderedReals = {}
    self.emitter = Emitter()
end

function World:init()
end

--- Convert user input to an action and set it
-- as the action of one of the players. 
-- returns true if the substitution was successful
-- and false otherwise
function World:setPlayerActions(action, playerIndex)
    local player = self.grid.players[playerIndex]

    if not player.isActionSet then
        player:setAction(action)
        return true
    end

    return false
end

--- This fuction would check if player actions have been set
-- and do the game loop if they have
function World:gameLoopIfSet()
    local players = self.grid.players
    for i = 1, #players do
        if not players[i].isActionSet then
            return false
        end
    end
    self:gameLoop()
    return true
end

function World:gameLoop(userInput)

    self.emitter:emit('game-loop:start')

    -- sort all game objects by prority
    self:sortByPriority()
    -- create a copy of the grid
    -- substitute it, and store the real one
    -- UPDATE: Here, we don't need a new copy. They should just calculate
    -- what type of action they're going to do, not in what direction
    -- it would be wacky otherwise

    -- self:substituteGridCopy()
    
    -- execute player actions 
    self:executePlayerActions()
    self:advancePhase()

    self:calculateActions()
    
    -- now sort reals depending on the speed that
    -- they figured out the actions with
    -- the ones that did it fast, will be the first ones

    -- return the stored grid
    -- self:restoreGrid()

    -- projectiles are also here. they have least priority
    -- and their action depends on the action of the player
    -- dropped items are too picked up here, as well as gold
    -- things that are not gere are:
    --      1. explosions
    --      2. traps
    --      3. floor
    --      4. walls
    self:executeActions()
    self:advancePhase()
    -- explode explosions
    self:activateExplosions()
    self:advancePhase()
    -- activate floor hazards
    self:activateFloorHazards()
    self:advancePhase()
    -- activate traps
    self:activateTraps()
    self:advancePhase()
    -- filter out dead things
    self:filterDead()

    -- set objects for rendering
    self:render()
    
    -- reset stored actions in objects
    -- reset the phase to 0
    self:reset()

    self.emitter:emit("game-loop:end")
end


function World:reset()
    self:resetPhase()
    -- set objects' actions to the None action
    self:resetObjects()
end

function World:resetPhase()
    self.phase = 0
end

function World:resetObjects()

end

function World:sortByPriority()
    -- sort everything in grid by priority
    self.grid:sortReals()
    self.grid:sortFloors()
    self.grid:sortWalls()
    self.grid:sortTraps()
    self.grid:sortProjectiles()
end


function World:substituteGridCopy()
    self.storedGrid = self.grid
    self.grid = self.grid:createSafeCopy()
end

function World:calculateActions()
    self.grid:calculateActionReals()    
    self.grid:calculateActionFloors()
    self.grid:calculateActionWalls()
    self.grid:calculateActionTraps()
    self.grid:calculateActionProjectiles()
end

function World:restoreGrid()
    self.grid = self.storedGrid
end

function World:executePlayerActions()
    for i = 1, #self.grid.players do
        self.grid.players[i]:executeSavedAction()
    end
end


function World:actionSelectedByReal(real)
    table.insert(self.orderedReals, real)
end


function World:executeActions()
    for i = 1, #self.orderedReals do
        if not self.orderedReals[i].didAction then
            self.orderedReals[i]:chainActions()
        end
    end
end


function World:activateExplosions()
end

function World:activateFloorHazards()
end

function World:activateTraps()
end

function World:filterDead()
    self.grid:filterDeadReals()
    self.grid:filterDeadFloors()
    self.grid:filterDeadWalls()
    self.grid:filterDeadTraps()
    self.grid:filterDeadProjectiles()    
end


-- Decorator + game logic stuff
local Move = require "logic.action.move"

function World:displace(target, move)
    local coord = Move.posFromMove(self.grid, target, move)

    if coord == nil then
        return false
    end

    self.grid:remove(target)
    target.coord = coord
    self.grid:reset(target)

    return true
end

function World:doAttack(actor, action)
    local weapon = actor.weapon
    
    local coord
    if weapon ~= nil then
        coord = weapon:posFromAction(action)
    else
        coord = actor.pos + action.direction
    end

    local target = self.grid:getRealAt(coord)
    
    if target == nil then
        return false
    end

    action.target = target

    return target:beAttacked(action)
end

function World:doPush(actor, action)
    local push = action.push
    
end

function World:doStatus(actor, action)
end
