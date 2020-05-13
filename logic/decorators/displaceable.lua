
local Decorator = require '@decorators.decorator'
local utils = require '@decorators.utils'
local Changes = require "render.changes"
local Move = require "@action.effects.move"

local Displaceable = class('Displaceable', Decorator)

local function convertFromMove(event)
    -- printf("Displacing %s", class.name(event.actor)) -- debug

    event.newPos = 
        event.move:toPos(
            event.actor.world.grid, 
            event.actor           
        )
end

local function displace(event)
    local actor = event.actor
    local grid = actor.world.grid

    grid:remove(actor)
    actor.pos = event.newPos
    grid:reset(actor)
end

Displaceable.affectedChains = {
    { "getDisplacement", 
        { 
            { convertFromMove, Ranks.HIGH } 
        } 
    },

    { "displace", 
        {
            { displace, Ranks.MEDIUM } 
        } 
    }
}

Displaceable.activate = 
    utils.checkApplyCustomized('getDisplacement', 'displace', 'move')

return Displaceable