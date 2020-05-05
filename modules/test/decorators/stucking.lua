local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Changes = require 'render.changes'
local HowToReturn = require 'logic.decorators.stats.howtoreturn'
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Ranks = require 'lib.chains.ranks'
local stuckTinker = require 'modules.test.tinkers.stuck'

DynamicStats.registerStat(
    'StuckRes',
    { -- stuck res
        'resistance',
        {
            'stuck', 1
        }
    },
    HowToReturn.NUMBER
)

-- Define our custom decorator
local Stucking = class("Stucking", Decorator)

-- a consideration:
-- Getting protection and stats is really troublesome right now. 
-- I think the entity should have a simpler interface for that.
-- Like getting already modified by items attack or move or protection
-- for each of them or whatever. The way we have it here is kind of awkward,
-- since this way the stuck parameters need to be set by default on every 
-- attack / move, which is not scalable at all.
--
-- IMPLEMENTED. take a look at the DynamicStats Decorator

    
local function getTarget(event)
    local actor = event.actor
    local entity = actor.world.grid:getRealAt(actor.pos)
    if entity == nil then
        event.propagate = false
    else
        event.target = entity
    end
end


local function checkAlreadySubmerged(event)
    -- avoid applying the next handler if already sumberged the entity
    event.propagate = event.actor.submergedEntity ~= event.target
end


local function submergeTarget(event)
    if 
        event.target:getStat(StatTypes.StuckRes) 
        < event.actor.baseModifiers.stuck.power
    then
        event.actor.submergedEntity = event.target  
        stuckTinker:tink(event.target)
    else
        event.propagate = false
    end
end


local function resetSubmergedEntity(event)
    local actor = event.actor
    local real = actor.world.grid:getRealAt(actor.pos)

    if real == nil then
        actor.submergedEntity = nil
    end
end

-- if the tile disappears, so should the handler
local function die(event)
    if event.actor.submergedEntity ~= nil then
        stuckTinker:untink(event.actor.submergedEntity)
    end
end


Stucking.affectedChains = {
    { 'getStuck', 
        { 
            getTarget, 
            checkAlreadySubmerged 
        } 
    },
    { 'stuck', 
        { 
            submergeTarget, 
            utils.regChangeFunc(Changes.Stuck)
        } 
    },
    { 'tick', 
        { 
            resetSubmergedEntity 
        } 
    },
    { 'die',
        {
            die
        }
    }
}

Stucking.activate = 
    utils.checkApplyCycle('getStuck', 'stuck')


return Stucking