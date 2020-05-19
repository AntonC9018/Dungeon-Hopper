local Statused = require '@decorators.statused'
local Status = require '@status.status'
local IceCube = require '.entities.icecube'
local StoreTinker = require '@tinkers.storetinker' 
local Target = require "@items.weapons.target"
local utils = require "@decorators.utils" 

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
    local function forbidMove(event)
        event.propagate = false
    end

    -- 1. reset targets to just. this way the other handlers
    --    are still passed through.
    -- 2. the second piece of logic of untinking if dead should
    --    be a separate handler.
    local function attackJustMe(event)
        -- assume the target is in the store
        local entity = tinker:getStore(event.actor)
        event.targets = utils.convertToTargets(
            { entity }, 
            event.action.direction, 
            event.actor
        )
    end

    local function selfRemove(event)
        local target = tinker:getStore(event.actor)
        if target.dead then
            event.actor.decorators.Statused:resetStatus(StatusTypes.bind)
            tinker:setStore(event.actor, nil)
        end
    end


    return {
        { 'getAttack', { attackJustMe, Ranks.HIGH } },
        { 'getMove',   { forbidMove,   Ranks.HIGH } },
        { 'tick',      { selfRemove,   Ranks.HIGH } }
    }
end

local tinker = StoreTinker(generator)
local bind = Status(tinker)
bind.amount = math.huge

return bind



