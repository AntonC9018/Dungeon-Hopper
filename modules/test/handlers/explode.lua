local Attack = require '@action.effects.attack'
local Push = require '@action.effects.push'
local Explosion = require '.effects.explosion'
local ExplodeInteractor = require '.interactors.explode'


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