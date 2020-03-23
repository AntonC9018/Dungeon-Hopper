local utils = require "utils" 

local Decorator = require 'decorator'
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
        { "defense", { utils.armor } },
        { "beHit", { takeHit, die } }
    }

Attackable.activate =
    utils.checkApplyCycle("defense", "beHit")

    
return Attackable