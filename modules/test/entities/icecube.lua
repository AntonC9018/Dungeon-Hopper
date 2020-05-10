local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Statused = require 'logic.decorators.statused'
local StatusTypes = Statused.StatusTypes
local Ranks = require 'lib.chains.ranks'


local IceCube = class("IceCube", Entity)

-- select layer
IceCube.layer = Cell.Layers.real
-- TODO: give it high priority in some normal way
IceCube.priority = 100000

-- select base stats
IceCube.baseModifiers = {
    resistance = {
        pierce = 1000,
        push = 1,
        explosion = 0
    },
    hp = {
        amount = 1
    }   
}

-- apply decorators
local decorate = require('logic.decorators.decorate')
local Decorators = require "logic.decorators.decorators"

Decorators.Start(IceCube)
decorate(IceCube, Decorators.Attackable)
decorate(IceCube, Decorators.Killable)
decorate(IceCube, Decorators.Pushable)
decorate(IceCube, Decorators.Displaceable)
decorate(IceCube, Decorators.DynamicStats)
decorate(IceCube, Decorators.WithHP)
-- ...

-- reset the position of the trapped entity on move
local function moveEntity(event)
    if event.actor.trappedEntity ~= nil then
        event.actor.trappedEntity.pos = event.actor.pos
    end
end

-- restore the trapped entity into the grid on death
local function freeEntity(event)
    local trappedEntity = event.actor.trappedEntity
    if trappedEntity ~= nil then
        trappedEntity.world.grid:reset(trappedEntity)
        local i = trappedEntity:getStat(StatTypes.Invincible)
        if i == 0 then
            trappedEntity:setStat(StatTypes.Invincible, 1) -- big hmm
        end
        -- reset the frozen status
        trappedEntity.decorators.Statused:resetStatus(StatusTypes.freeze)
    end
end

local retouch = require('logic.retouchers.utils').retouch
retouch(IceCube, 'displace', { moveEntity, Ranks.LOWEST })
retouch(IceCube, 'die',      { freeEntity, Ranks.LOWEST })


-- TEST
-- function IceCube:beStatused(...)
--     if self.trappedEntity ~= nil then
--         self.trappedEntity:beStatused(...)
--     end
-- end


return IceCube