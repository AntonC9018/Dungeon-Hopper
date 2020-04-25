local utils = require "logic.decorators.utils" 

local Decorator = require 'logic.decorators.decorator'
local Explodable = class('Explodable', Decorator)

-- TODO: fully implement
local function beExploded(event)
    event.actor:takeDamage(event.action.special.damage)    
end

Explodable.affectedChains = {
    { "defence", { utils.setAttackRes, utils.armor }},
    { "beingExploded", { beExploded, utils.die } }
}

Explodable.activate = 
    utils.checkApplyCycle("defence", "beingExploded")

return Explodable