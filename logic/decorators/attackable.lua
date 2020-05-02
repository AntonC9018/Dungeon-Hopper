local utils = require "logic.decorators.utils" 
local Changes = require 'render.changes'
local Decorator = require 'logic.decorators.decorator'
local Ranks = require 'lib.chains.ranks'

local Attackable = class('Attackable', Decorator)


local function takeHit(event)
    event.actor:takeDamage(event.action.attack.damage)    
end


Attackable.affectedChains =
    { 
        { "defence", 
            { 
                { utils.setAttackRes, Ranks.HIGH }, 
                { utils.armor, Ranks.LOW } 
            } 
        },

        { "beHit", 
            { 
                { takeHit,   Ranks.LOW }, 
                { utils.die, Ranks.LOW } 
            }
        },
        { "attackableness", {} }
    }

Attackable.activate =
    utils.checkApplyCycle("defence", "beHit")


local Attackableness = require "logic.enums.attackableness"

-- checking to what degree it is possible to attack    
-- see logic.enums.attackableness 
function Attackable:getAttackableness(actor, attacker)
    local event = Event(actor, nil)
    event.attacker = attacker

    actor.chains.attackableness:pass(event, Chain.checkPropagate)

    -- no functions check
    if event.result == nil then
        return Attackableness.YES
    end
    
    return event.result
end
    

return Attackable
