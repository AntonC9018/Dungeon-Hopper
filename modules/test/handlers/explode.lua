local Attack = require 'logic.action.effects.attack'
local Push = require 'logic.action.effects.push'
local Explosion = require 'modules.test.explosion'

local explode = {}

explode.base = function(event)
    local attack = Attack(event.actor.baseModifiers.attack)
    local push =   Push(event.actor.baseModifiers.push)
    local radius = event.actor.baseModifiers.explosion.radius
    local power =  event.actor.baseModifiers.explosion.power
    
    local pos = event.actor.pos

    -- instantiate explosions all around the pos
    for i = -radius, radius do
        for j = -radius, radius do
            local offset = Vec(i, j)
            local dir = offset:normComps()
            local expl = event.actor.world:create( 
                Explosion, pos + offset
            )
            expl:set({ 
                attack = attack,
                push = push,
                power = power,
                direction = dir
            })
        end
    end
end


-- TODO: implement
explode.dynamic = function(event)
    local attack = event.actor:getStat()
    local push =   Push(event.actor.baseModifiers.push)
    local radius = event.actor.baseModifiers.explosion.radius
    local power =  event.actor.baseModifiers.explosion.power
    
    local pos = event.actor.pos

    -- instantiate explosions all around the pos
    for i = -radius, radius do
        for j = -radius, radius do
            local offset = Vec(i, j)
            local dir = offset:normComps()
            local expl = event.actor.world:create( 
                Explosion, offset
            )
            expl:set({ 
                attack = attack,
                push = push,
                power = power,
                direction = dir
            })
        end
    end
end

return explode