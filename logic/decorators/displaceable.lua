
local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Changes = require "render.changes"
local Move = require "logic.action.effects.move"
local Ranks = require 'lib.chains.ranks'

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

    -- problem: bumping is always activated, if displace comes first
    -- resolution: set the right priority for chains
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