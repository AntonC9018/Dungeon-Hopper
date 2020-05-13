local utils = require "@decorators.utils" 
local Changes = require "render.changes"
local Decorator = require '@decorators.decorator'

local Killable = class('Killable', Decorator)


function die(event)
    event.actor.dead = true
    event.actor.world:removeDead(event.actor)
end

Killable.affectedChains = {
    { "checkDie", {} },
    { "die", 
        { 
            die, 
            utils.regChangeFunc(Changes.Dead) 
        } 
    }
}

Killable.activate =
    utils.checkApplyCycle("checkDie", "die")


return Killable