local Statused = require '@decorators.statused'
local FlavorStatus = require '@status.flavor'
local IceCube = require '.entities.icecube'
local StoreTinker = require '@tinkers.storetinker' 
local Target = require "@items.weapons.target"
local utils = require "@decorators.utils" 
local Changes = require 'render.changes'

-- 
-- + 1. Prevent moving
-- + 2. Instead of attacking, deal damage to the entity that applied the effect
--   3. Absorb damage from bombs
--
-- There is one problem. To deal damage to the thing that got us bound, 
-- we need to have some reference to that thing. We can't reach out for 
-- the grid, since entity removes itself off of it after the effect has been 
-- applied and we do not know where it is before it has been applied.
-- We can't get the entity when the statuses are applied, since no reference 
-- to the entity is passed when that happens.
-- There are some solutions to this:
--      1. pass a reference to the actor with action (I think this is bad, 
--         though I think it would be fine for some specific statuses that
--         require this behavior). Even then, the way status effects are 
--         applied has to be tweaked. right now, the only thing is passed
--         is the entity and the amount of effect applied.
--      2. apply the status effect -> an empty store for that target entity
--         is created on effect -> get the store from the action component
--         that applied the status and put the reference to the one who 
--         applied it into the store -> reference them within the tinker
--      3. put the entity who did the bind in a special layer in the cell.
--         This is fine if the cell layers are scalable, which they currently
--         aren't.
--
-- The second one feels like a workaround. Additionally it merges the logic of binding 
-- decorator and the bind effect instead of separating them, but it is the best
-- solution for now. 


local function generator(tinker)

    -- 1. reset targets to just. this way the other handlers
    --    are still passed through.
    -- 2. the second piece of logic of untinking if dead should
    --    be a separate handler.
    local function attackJustMe(event)
        -- assume the target is in the store
        local whoApplied = tinker:getStore(event.actor).whoApplied
        event.targets = utils.convertToTargets(
            { whoApplied }, 
            event.action.direction, 
            event.actor
        )
    end

    local function selfRemove(event)
        local whoApplied = tinker:getStore(event.actor).whoApplied
        if whoApplied ~= nil and whoApplied.dead or whoApplied == nil then
            event.actor.decorators.Statused:resetStatus(StatusTypes.bind)
            tinker:setStore(event.actor, nil)
        end
    end

    local function displaceMe(event)
        local whoApplied = tinker:getStore(event.actor).whoApplied
        if whoApplied ~= nil then
            whoApplied.pos = event.actor.pos
            event.actor.world:registerChange(whoApplied, Changes.Move)
        end
    end

    return {
        { 'getAttack', { attackJustMe, Ranks.HIGH } },
        { 'tick',      { selfRemove,   Ranks.HIGH } },
        { 'displace',  { displaceMe,   Ranks.LOW  } }
    }
end

local tinker = StoreTinker(generator)

-- The required options: whoApplied = entity who applied the status effect.
-- optional ones:        flavor = any flavor
local bind = FlavorStatus(tinker)
bind.amount = math.huge

return bind



