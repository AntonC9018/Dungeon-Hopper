local Grid = require "world.grid"

local World = class("World")

local Player = require 'logic.base.player'
local TestEnemy = require 'modules.test.enemytest'
local Tile = require 'modules.test.tile'
local Changes = require 'render.changes'
local Dirt = require 'modules.test.dirt'
local Trap = require 'modules.test.trap' 

function World:__construct(renderer, w, h)
    self.grid = Grid(w, h)
    self.orderedReals = {}
    self.emitter = Emitter()
    self.renderer = renderer
    self.changes = {{}}
    self.phase = 1
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

    local dirtType = assets:getObjectType(Dirt)
    assets:registerGameObjectType(dirtType)

    local trapType = assets:getObjectType(Trap)
    assets:registerGameObjectType(trapType)
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

function World:createDirtAt(pos)
    local dirt = Dirt()
    dirt:init(pos, self)
    self.grid:setWallAt(dirt, pos)
    self.renderer:addRenderEntity(dirt)
    return dirt
end

function World:createTrapAt(pos)
    local trap = Trap()
    trap:init(pos, self)
    self.grid:setTrapAt(trap, pos)
    self.renderer:addRenderEntity(trap)
    return trap
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

    self.emitter:emit("game-loop:end")
end


function World:reset()
    self:resetPhase()
    -- set objects' actions to the None action
    self:resetObjects()
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
end


function World:sortByPriority()
    -- sort everything in grid by priority
    self.grid:sortReals()
    self.grid:sortFloors()
    self.grid:sortWalls()
    self.grid:sortTraps()
    self.grid:sortProjectiles()
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
    self.grid:calculateActionsReals()    
    self.grid:calculateActionsFloors()
    self.grid:calculateActionsWalls()
    self.grid:calculateActionsTraps()
    self.grid:calculateActionsProjectiles()
end


function World:executePlayerActions()
    for i = 1, #self.grid.players do
        self.grid.players[i]:executeAction()
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


function World:activateExplosions()
end


function World:activateFloors()
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


function World:filterDead()
    self.grid:filterDeadPlayers()
    self.grid:filterDeadReals()
    self.grid:filterDeadFloors()
    self.grid:filterDeadWalls()
    self.grid:filterDeadTraps()
    self.grid:filterDeadProjectiles()    
end



-- Decorator + game logic stuff
local Target = require "items.weapons.target"
local Piece = require "items.weapons.piece"

local function doX(funcName)
    return function(self, targets, action)
        if targets == nil then
            return {}
        end
        local events = {}
        for i = 1, #targets do
            local entity = targets[i].entity
            action.direction = targets[i].piece.dir
            events[i] = entity[funcName](entity, action)
        end
        return events
    end
end

-- define all do<something> functions
World.doAttack = doX('beAttacked')
World.doDig    = doX('beDug')
World.doPush   = doX('bePushed')
World.doStatus = doX('beStatused')


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

return World