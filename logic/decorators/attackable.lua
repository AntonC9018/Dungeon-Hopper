local utils = require "@decorators.utils" 
local Changes = require 'render.changes'
local Decorator = require '@decorators.decorator'
local DynamicStats = require '@decorators.dynamicstats'
local AttackEffect = require '@action.effects.attack'

local Attackable = class('Attackable', Decorator)

Attackable.AttackSourceTypes = {
    -- map string -> string. See below
    Normal = 'normal'
}


-- the idea is to set the used source at attack
-- There is a problem
-- The thing is, resistances are accessed via strings inside the stats
-- object of AttackRes while storing values, however the attack's source
-- parameter is stored as an index into the names array. There has to
-- be a compromise to prevent constant remapping from string to index
-- and vice versa.
--
-- Like you would do this to get the resistance you need without a compromise:
-- `attackRes:get(Attackable.AttackSourceTypes[attack.source])`
--
-- and this is what you would use with one:
-- `attackRes:get(attack.source)
--
-- Compromises:
--      1. We store sources as strings on both AttackRes stat and the attack
--         this is ok, but stats are assumed to store integers, so this feels
--         wrong.  
--      2. We store it as integers, that is, keys in stats are integeres. 
--         This will cause problems with the stats API since it uses pairs() and
--         not ipairs(). Also it would make serialized resistances hard 
--         to understand.
--
-- I'm going to opt for the first compromise: store everything as strings.
-- It may need changes into the DynamicStats decorator, but I'm not sure yet.
--  
-- There is also a slight problem with strings. We can't use enums. 
-- Technically we could map strings to themselves, just for strictness 
-- sake. I think I want to have that. 
-- For such sorts of things I like to have 'PascalCase' to 'flatcase' conversion
-- P.S. actually, I've changed my mind
--
-- One other possibility would be to have an entry for the attacks of
-- each of the sources. I will think about this possibility later and
-- maybe reimplement some of this.
--
-- Now need to do the same for pushing

Attackable.registerAttackSource = function(name)
    local lowerName = string.lower(name)
    Attackable.AttackSourceTypes[name] = lowerName

    -- now, gotta modify the DynamicStats to include it in resistances
    DynamicStats.addAttribute(
        StatTypes.AttackRes, 
        { lowerName, 1 }
    )
end


local function setAttackRes(event)
    event.resistance = event.actor:getStat(StatTypes.AttackRes)
end

local function resistSource(event)
    local attack = event.action.attack
    event.propagate = 
        event.resistance:get(attack.source) <= attack.power
end

local function armor(event)
    local actor = event.actor
    -- A: this should probably be expandable
    -- that is, resistances should be an object (specific to e.g. attack)
    -- saved on the event. Possibly a Resistances decorator?
    -- yet another thing to consider... やれやれ...
    -- B: this should obviously be exapndable, since items could
    -- modify the armor and piercing parameters
    -- DONE!!!! (DynamicStats decorator)
    local attack = event.action.attack

    attack.damage = 
        clamp(
            attack.damage - event.resistance:get('armor'), 
            event.resistance:get('minDamage'), 
            event.resistance:get('maxDamage')
        )
        
    if attack.pierce <= event.resistance:get('pierce') then
        attack.damage = 0
    end
end

local function takeHit(event)
    event.actor:takeDamage(event.action.attack.damage)    
end

Attackable.affectedChains =
    { 
        { "defence", 
            { 
                { setAttackRes, Ranks.HIGH },
                { resistSource, Ranks.LOW }, 
                { armor,        Ranks.LOW } 
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


local Attackableness = require "@enums.attackableness"

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
