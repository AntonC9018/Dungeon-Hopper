local Statused = require 'logic.decorators.statused'
local Status = require 'logic.status.status'
local IceCube = require 'modules.test.icecube'
local PreventActionTinker = require 'modules.test.tinkers.preventaction' 

-- I want to try out a freeze like that of COH where it gives invincibility
-- The idea is to:
--  +   1. stop player's actions
--  +   2. spawn a new entity (ice block) on top of player, that would take 
--         its place in the grid and keep the player inside it
--  +   3. kill this entity once the status ticks off
--  +   4. restore player's position in the grid
--  +   5. give it invincibility of 1 so that they don't take damage right
--         after the freeze.
--  +   6. have this ice block be destroyed immediately on explosions
--  +   7. have it be invincible to normal attacks, but be pushable


local function forbidAction(event)
    event.propagate = false
end

local Freeze = class("Freeze", Status)

function Freeze:__construct()
    self.store = {}
    self.tinker = PreventActionTinker
end

function Freeze:apply(entity)
    -- remove entity from grid
    entity.world.grid:remove(entity)
    -- instantiate an ice cube
    local iceCube = entity.world:create( IceCube, entity.pos )
    -- let it know what it's holding
    iceCube.trappedEntity = entity
    -- store the ice cube
    self.store[entity.id] = iceCube
    -- set up the handlers
    self.tinker:tink(entity)
end

function Freeze:wearOff(entity)
    local iceCube = self.store[entity.id]
    self.store[entity.id] = nil
    iceCube:die()
    self.tinker:untink(entity)
    entity.world.grid:reset(entity)
end

local freeze = Freeze()

-- register the new stat
Statused.registerStatus('freeze', freeze)


return freeze



