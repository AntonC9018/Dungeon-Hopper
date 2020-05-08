local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Bounce = require 'modules.test.effects.bounce'
local Changes = require 'render.changes'
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local DynamicStats = require 'logic.decorators.dynamicstats'
local HowToReturn = require 'logic.decorators.stats.howtoreturn'
local Ranks = require 'lib.chains.ranks'
local Attackableness = require 'logic.enums.attackableness'

DynamicStats.registerStat(
    'ProjRes',
    { -- stuck res
        'resistance',
        {
            'proj', 1
        }
    },
    HowToReturn.NUMBER
)

-- Define our custom decorator
local ProjDec = class("ProjDec", Decorator)


local function unattackableAfterCheck(event)
    event.propagate = not
        ( event.targets[1].attackableness == Attackableness.NO 
          or event.targets[1].attackableness == Attackableness.SKIP )
end

local function projAfterCheck(event)
    local res = event.targets[1].entity:getStat(StatTypes.ProjRes)
    event.propagate = res <= event.actor.baseModifiers.proj
end


local function watch(event)
    -- if did hit anything watch the cell for a beat
    if not event.actor.dead then
        event.actor.world.grid:watchBeat(
            event.actor.pos,
            function(entity)
                if not event.actor.dead then
                    event.actor:executeAttack(event.action, { entity })
                end
            end
        )
    end
end


ProjDec.affectedChains = {
    { 'attack', 
        { 
            { unattackableAfterCheck, Ranks.HIGH },
            { projAfterCheck,         Ranks.HIGH }
        } 
    },
    { 'move',
        {
            { watch, Ranks.LOW }
        }
    }
}

function ProjDec:activate(actor, action)
    -- attack the real at our spot only if it looks 
    -- in the opposite to our movement direction
    local real = actor.world.grid:getRealAt(actor.pos)
    if 
        real ~= nil
        and real.orientation.x == -actor.orientation.x 
        and real.orientation.y == -actor.orientation.y
    then
        return actor:executeAttack(action, { real })
    end

    -- not succeeded, try next action
    return { success = false }
end

return ProjDec