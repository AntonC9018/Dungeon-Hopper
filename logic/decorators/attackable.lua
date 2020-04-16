local utils = require "logic.decorators.utils" 

local Decorator = require 'logic.decorators.decorator'
local Attackable = class('Attackable', Decorator)


-- TODO: fully implement
local function takeHit(event)
    event.actor:takeDamage(event.action.attack.damage)    
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end
    
end


Attackable.affectedChains =
    { 
        { "defence", { utils.armor } },
        { "beHit", { takeHit, die } }
    }

Attackable.activate =
    utils.checkApplyCycle("defence", "beHit")

    
return Attackable