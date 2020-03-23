local utils = require "utils" 

local Decorator = require 'decorator'
local Explodable = class('Explodable', Decorator)

-- TODO: fully implement
local function beExploded(event)
    event.actor:takeDamage(event.action.special.damage)    
end

local function die(event)
    if event.actor.hp:get() <= 0 then
        event.actor.dead = true
        event.actor:die()
    end    
end


Explodable.affectedChains = {
    { "defense", { armor(entityClass.baseModifiers.armor) }},
    { "beingExploded", { beExploded, die } }
}

Explodable.activate = 
    utils.checkApplyCycle("defence", "beingExploded")
    
return Explodable