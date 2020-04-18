local Grid = require "world.grid"

local World = class("World")

local Player = require 'logic.base.player'
local TestEnemy = require 'modules.test.enemytest'
local Tile = require 'modules.test.tile'

function World:__construct(renderer, w, h)
    self.grid = Grid(w, h)
    self.orderedReals = {}
    self.emitter = Emitter()
    self.renderer = renderer
end


function World:init()
end

function World:registerTypes(assets)
    -- register all assets
    local playerType = assets:getObjectType(Player)
    assets:registerGameObjectType(playerType)

    local enemyType = assets:getObjectType(TestEnemy)
    assets:registerGameObjectType(enemyType)

    local tileType = assets:getObjectType(Tile)
    assets:registerGameObjectType(tileType)
end


-- player and entity creation

function World:createPlayerAt(pos)
    local player = Player()
    player:init(pos, self)
    self.grid:setPlayerAt(player, pos)
    self.renderer:addRenderEntity(player)
    self.renderer:setAsPlayer(player.id)
    return player
end

function World:createFloors()
    for i = 1, #self.grid.grid do
        for j = 1, #self.grid.grid[1] do
            self:createFloorAt( Vec(i, j) )
        end
    end
end

function World:createFloorAt(pos)
    local tile = Tile()
    tile:init(pos, self)
    self.grid:setFloorAt(tile, pos)
    self.renderer:addRenderEntity(tile)
    return tile
end

function World:createTestEnemyAt(pos)
    local testEnemy = TestEnemy()
    testEnemy:init(pos, self)
    self.grid:setRealAt(testEnemy, pos)
    self.renderer:addRenderEntity(testEnemy)
    return testEnemy
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
    self:activateFloors()
    self.grid:tickFloors()
    self:advancePhase()

    -- activate traps
    -- self:activateTraps()
    -- self.grid:tickTraps()
    -- self:advancePhase()

    -- TODO: refine
    -- for now, save the final state of all objects as the changes
    self:resetChangesToCurrentStates()

    -- update render states for all objects 
    self:updateRenderStates()

    -- filter out dead things
    self:filterDead()
    
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
        self.grid.players[i]:executeAction()
    end
end


function World:actionSelectedByReal(real)
    table.insert(self.orderedReals, real)
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


function World:activateExplosions()
end


function World:activateFloors()
end


function World:activateTraps()
end


function World:filterDead()
    self.grid:filterDeadPlayers()
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
    -- printf("Getting targets %s", class.name(actor)) -- debug

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
    -- printf("Doing attack %s", class.name(targets[1].target)) -- debug

    local events = {}
    for i = 1, #targets do
        local target = targets[i].target
        action.direction = targets[i].piece.dir
        events[i] = target:beAttacked(action)
    end
    return events
end


function World:doPush(targets, action)
    -- printf("Doing push %s", class.name(targets[1].target)) -- debug

    local events = {}

    for i = 1, #targets do
        events[i] = targets[i].target:bePushed(action)
    end
    return events
end


function World:doStatus(targets, action)
    -- printf("Doing status %s", class.name(targets[1].target)) -- debug

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


function World:removeDead(entity)
    self.grid:remove(entity)
end


function World:updateRenderStates()

    -- print(ins(self.changes, {depth = 2})) -- debug
    
    if self.renderer ~= nil then
        self.renderer:pushChanges(self.changes)
        return
    end
    
    -- provisional rendering through console
    local grid = self.grid.grid
    for i = 1, #grid do
        local str = ""
        for j = 1, #grid[1] do
            local real
            for k = 1, #self.grid.reals do
                if 
                    self.grid.reals[k].pos.x == i 
                    and self.grid.reals[k].pos.y == j 
                then
                    real = self.grid.reals[k]
                end
            end
            if real == nil then
                str = str.."- "
            elseif real.dead then                
                str = str.."x "
            else
                str = str.."o "
            end
        end
        print(str)
    end
end


-- TODO: do this for all things, not just reals
function World:resetChangesToCurrentStates()

    self.changes = {}

    for i, real in ipairs(self.grid.reals) do
        table.insert(self.changes, 
            {
                id = real.id,
                pos = real.pos,
                orientation = real.orientation,
                state = real.state
            }
        )
    end

end

return World