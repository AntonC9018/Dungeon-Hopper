local utils = require "@decorators.utils" 
local Changes = require "render.changes"
local Decorator = require '@decorators.decorator'
local Stats = require '@stats.stats' 
local Attack = require '@action.effects.attack'
local Push = require '@action.effects.push'
local Do = require '@interactors.do'

local Attacking = class('Attacking', Decorator)

local function setBase(event)
    event.action.attack = event.actor:getStat(StatTypes.Attack)
    event.action.status = event.actor:getStat(StatTypes.Status)
    event.action.push =   event.actor:getStat(StatTypes.Push)  
end

-- this should have medium priority so that
-- it is possible to first apply all piercing and stuff
-- and then check if able to attack.
-- For example take the ghost that CAN BE ATTACKED only if your level of 
-- piercing is significantly high. In contast, an enemy with piercing 
-- protection, e.g. shielded enemies are ABLE TO BE ATTACKED, that is, 
-- if you try to attack them, they'll let you, but there'll be no damage.
-- Ghosts, however, won't allow you to attack them if you wouldn't pierce 
-- the high protection level. This way, ghosts will work by adding
-- a handler onto their `Attackable.attackableness` chain, which is traversed
-- when this function (getTargets) is called. That function would compare
-- the piercing levels and tell the system the ghost can't be attacked
-- if your piercing is not high enough. If there were no way to add 
-- functions before this one, the ghost could never know the real 
-- piercing levels.
--
local function getTargets(event)
    -- Another thing: the targets may be provided manually. 
    -- TODO: think about this a bit more. Thing is, there's just three things
    -- shared between these handlers and the actor: the actor object itself,
    -- which should not be used as a buffer (feels hacky), the action object,
    -- which probably shouldn't contain anything about targets (feels wrong),
    -- or a handler before this one, which would set the targets beforehand
    -- (feels wrong again, because of this useless in most cases check)
    -- giving e.g. projectiles weapons also seems weird and they share the problem
    -- I guess the best way is to have same getTargets functions whenever possible
    -- but then there is the wasted extra effort on retrieving these targets while
    -- one already has them at hand.
    -- UDPATE: I have actually settled on adding this check. This seems helpful for
    -- e.g. monkeys (spiders), which set the targets of the bound entity manually
    -- (see modules/test/status/bind.lua)
    if event.targetEntities ~= nil then 
        event.targets = utils.convertToTargets(
            event.targetEntities, 
            event.action.direction, 
            event.actor
        )
        return
    end
    -- for now, i'm going to settle on providing the targets manually 
    -- passing them as arguments to the activation
    -- that seems the most reasonable approach at this point    
    if event.targets == nil then
        local targets = event.actor:getTargets(event.action)
        event.targets = targets
    end
end

local function applyAttack(event)
    local events = Do.attack(event.targets, event.action)
    event.attackEvents = events
end

local function applyPush(event)
    local events = Do.push(event.targets, event.action)
    event.pushEvents = events    
end

local function applyStatus(event)
    local events = Do.status(event.targets, event.action)
    event.statusEvents = events    
end

Attacking.affectedChains = {
    { "getAttack", 
        { 
            { setBase, Ranks.HIGH }, 
            getTargets 
        } 
    },

    { "attack", 
        { 
            applyAttack, 
            applyPush, 
            applyStatus, 
            utils.regChangeFunc(Changes.Hits) 
        } 
    }
}


local checkApply = 
    utils.checkApplyPresetEvent("getAttack", "attack")


-- targets are optional
-- TODO: pass additional parameters via an object
function Attacking:activate(actor, action, targetEntities)
    local event = Event(actor, action)
    -- if target entities are provided
    event.targetEntities = targetEntities
    return checkApply(event)
end


return Attacking