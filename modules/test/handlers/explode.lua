local Attack = require 'logic.action.effects.attack'
local Push = require 'logic.action.effects.push'
local Explosion = require 'modules.test.effects.explosion'
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local ExplodeInteractor = require 'modules.test.interactors.explode'


local explode = {}

explode.default = function(event)
    ExplodeInteractor.cell(
        event.actor.world, 
        event.actor.pos, 
        Vec(0, 0)
    )
end


explode.dynamic = function(event)
    -- attack and push are assumed to have been 
    -- set manually on the expl stat
    ExplodeInteractor.radius(
        event.actor.world, 
        event.actor.pos, 
        event.expl
    )
end

return explode