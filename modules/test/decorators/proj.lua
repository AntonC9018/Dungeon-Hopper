local Decorator = require '@decorators.decorator'
local utils = require '@decorators.utils'
local Changes = require 'render.changes'

-- Define our custom decorator
local ProjDec = class("ProjDec", Decorator)

-- store this by name 'Projectile' in the list of Decorators
USE_NAME = 'Projectile'


local function unattackableAfterCheck(event)
    event.propagate = not
        ( event.targets[1].attackableness == Attackableness.NO 
          or event.targets[1].attackableness == Attackableness.SKIP )
end

local function watch(event)
    local actor = event.actor
    -- if did hit anything watch the cell for a beat
    actor.world.grid:watchOnto(
        actor.pos,
        function(entity)
            if not actor.dead then
                actor:executeAttack(event.action, { entity })
            end
        end,
        1
    )
end


ProjDec.affectedChains = {
    { 'attack', 
        { 
            { unattackableAfterCheck, Ranks.HIGH }
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