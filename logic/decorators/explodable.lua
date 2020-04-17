local utils = require "logic.decorators.utils" 

local Decorator = require 'logic.decorators.decorator'
local Explodable = class('Explodable', Decorator)

-- TODO: fully implement
local function beExploded(event)
    event.actor:takeDamage(event.action.special.damage)    
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor:die()
    end    
end


Explodable.affectedChains = {
    { "defence", { utils.armor }},
    { "beingExploded", { beExploded, die } }
}

Explodable.activate = 
    utils.checkApplyCycle("defence", "beingExploded")

return Explodable