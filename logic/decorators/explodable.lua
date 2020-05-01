local utils = require "logic.decorators.utils" 

local Decorator = require 'logic.decorators.decorator'
local Explodable = class('Explodable', Decorator)
local Ranks = require 'lib.chains.ranks'

-- TODO: fully implement
local function beExploded(event)
    event.actor:takeDamage(event.action.special.damage)    
end

Explodable.affectedChains = {
    { "defenceExplode", 
        { 
            utils.setAttackRes, 
            utils.armor 
        }
    },
    { "beingExploded", 
        { 
            beExploded, 
            { utils.die, Ranks.LOW }
        } 
    }
}

Explodable.activate = 
    utils.checkApplyCycle("defenceExplode", "beingExploded")

return Explodable