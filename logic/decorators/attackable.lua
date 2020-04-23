local utils = require "logic.decorators.utils" 
local Changes = require 'render.changes'

local Decorator = require 'logic.decorators.decorator'
local Attackable = class('Attackable', Decorator)


local function setBase(event)
    event.protection = {
        
    }
end

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
        { "defence", { setBase, utils.armor } },
        { "beHit", { takeHit, die } },
        { "canBeAttacked", {} }
    }

Attackable.activate =
    utils.checkApplyCycle("defence", "beHit")


local Attackableness = require "logic.enums.attackableness"

-- checking to what degree it is possible to attack    
-- see logic.enums.attackableness 
function Attackable:getAttackableness(actor, attacker)
    local event = Event(actor, nil)
    event.attacker = attacker

    actor.chains.attackableness:pass(event, Event.checkPropagate)

    -- no functions check
    if event.result == nil then
        return Attackableness.YES
    end
    
    return event.result
end
    

return Attackable
