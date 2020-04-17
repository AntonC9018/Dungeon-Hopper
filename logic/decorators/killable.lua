local utils = require "logic.decorators.utils" 

local Decorator = require 'logic.decorators.decorator'
local Killable = class('Killable', Decorator)


function die(event)
    event.actor.dead = true
    event.actor.world:removeDead(event.actor)
end

Killable.affectedChains = {
    { "checkDie", {} },
    { "die", { die } }
}

Killable.activate =
    utils.checkApplyCycle("checkDie", "die")


return Killable