local Grid = require("world.grid")

local World = class("World")


function World:__construct(w, h)
    self.grid = Grid(w, h)
    self.orderedReals = {}
    self.emitter = Emitter()
end


function World:init()
end


-- player and entity creation
local Player = require 'logic.base.player'

function World:createPlayerAt(pos)
    local player = Player()
    player:init(pos, self)
    self.grid:setPlayerAt(player, pos)
    return player
end


local TestEnemy = require 'modules.test.enemytest'

function World:createTestEnemyAt(pos)
    local testEnemy = TestEnemy()
    testEnemy:init(pos, self)
    self.grid:setRealAt(testEnemy, pos)
    return testEnemy
end

--- Convert user input to an action and set it
-- as the action of one of the players. 
-- returns true if the substitution was successful
-- and false otherwise
function World:setPlayerActions(direction, playerIndex)
    local player = self.grid.players[playerIndex]

    if not player.isActionSet then
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
        if not players[i].isActionSet then
            return false
        end
    end
    self:gameLoop()
    return true
end


function World:gameLoop()

    self.emitter:emit('game-loop:start')

    -- sort all game objects by prority
    self:sortByPriority()
    
    -- execute player actions 
    self:executePlayerActions()
    self:advancePhase()

    self:calculateActions()
    
    -- execute projectile actions
    -- self:activateProjectiles()
    -- self.grid:tickProjectiles()
    -- self:advancePhase()

    -- execute reals' actions
    self:activateReals()
    self.grid:tickReals()
    self:advancePhase()

    -- explode explosions
    -- self:activateExplosions()
    -- self:advancePhase()

    -- activate floor hazards
    -- self:activateFloors()
    -- self.grid:tickFloors()
    -- self:advancePhase()

    -- activate traps
    -- self:activateTraps()
    -- self.grid:tickTraps()
    -- self:advancePhase()

    -- filter out dead things
    self:filterDead()

    -- set objects for rendering
    -- self:render()
    
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


-- TODO: implement
function World:advancePhase()

end


-- NOTE: this should select an action (Attack, Move etc)
-- and set it as the nextAction at that object
-- it should not care much about direction
-- These functions should not be used to tick internal state,
-- that is, e.g. the sequence step. The thing that tick stuff 
-- is the tick() method
function World:calculateActions()
    self.grid:calculateActionsReals()    
    self.grid:calculateActionsFloors()
    self.grid:calculateActionsWalls()
    self.grid:calculateActionsTraps()
    self.grid:calculateActionsProjectiles()
end


function World:restoreGrid()
    self.grid = self.storedGrid
end


function World:executePlayerActions()
    for i = 1, #self.grid.players do
        print("do action")
        self.grid.players[i]:executeAction()
    end
end


function World:actionSelectedByReal(real)
    table.insert(self.orderedReals, real)
end


function World:activateReals()
    for i = 1, #self.grid.reals do
        if not self.grid.reals[i].didAction then
            self.grid.reals[i]:executeAction()
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
local Move = require "logic.action.effects.move"


function World:displace(target, move)
    printf("Displacing %s", class.name(target)) -- debug

    local newPos = Move.posFromMove(self.grid, target, move)
    
    if newPos == nil then
        return nil
    end

    self.grid:remove(target)
    target.pos = newPos
    self.grid:reset(target)

    return true
end



local Target = require "items.weapons.target"
local Piece = require "items.weapons.piece"


function World:getTargets(actor, action)
    printf("Getting targets %s", class.name(actor)) -- debug

    local weapon = actor.weapon

    if weapon ~= nil then
        return weapon:hitsFromAction(actor, action)
    end

    local coord = actor.pos + action.direction
    local real = self.grid:getRealAt(coord)

    if real == nil then
        return nil
    end

    local piece = Piece(coord, action.direction, false)
    local target = Target(real, piece, 1)
    return { target }
end


function World:doAttack(targets, action)
    -- printf("Doing attack %s", class.name(targets[1])) -- debug

    local events = {}
    for i = 1, #targets do
        local target = targets[i].target
        action.direction = targets[i].piece.dir
        events[i] = target:beAttacked(action)
    end
    return events
end


function World:doPush(targets, action)
    printf("Doing push %s", class.name(targets[1])) -- debug

    local events = {}

    for i = 1, #targets do
        events[i] = targets[i].target:bePushed(action)
    end
    return events
end


function World:doStatus(targets, action)
    printf("Doing status %s", class.name(targets[1])) -- debug

    local events = {}
    for i = 1, #targets do
        events[i] = targets[i].target:beStatused(action)
    end
    return events
end


function World:getOneFromTopAt(pos)
    local result
    result = self.grid:getRealAt(pos)
    if result ~= nil then return result end
    result = self.grid:getProjectileAt(pos)
    if result ~= nil then return result end
    result = self.grid:getWallAt(pos)
    if result ~= nil then return result end
    result = self.grid:getTrapAt(pos)
    return result
end



return World