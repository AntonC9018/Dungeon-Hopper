local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local DynamicStats = require '@decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Attackableness = require '@enums.attackableness'
local Ranks = require 'lib.chains.ranks'
local Action = require '@action.action'
local handlerUtils = require '@action.handlers.utils' 

local Projectile = class("Projectile", Entity)

-- select layer
Projectile.layer = Cell.Layers.projectile

-- select base stats
Projectile.baseModifiers = {
    move = {
        ignore = 1,
        distance = 1
    },
    proj = 1,
    hp = {
        amount = 1
    }   
}


-- apply decorators
local decorate = require('@decorators.decorate')
local Decorators = require "logic.decorators.decorators"

Decorators.Start(Projectile)
decorate(Projectile, Decorators.Acting)
decorate(Projectile, Decorators.Attacking)
decorate(Projectile, Decorators.Attackable)
decorate(Projectile, Decorators.Killable)
decorate(Projectile, Decorators.Moving)
decorate(Projectile, Decorators.Displaceable)
decorate(Projectile, Decorators.DynamicStats)
decorate(Projectile, Decorators.WithHP)
-- ...


local ActionState = {
    Beneath = 1,
    Normal = 2
}

local function unattackableAfterCheck(event)
    event.propagate = not
        ( event.targets[1].attackableness == Attackableness.NO 
          or event.targets[1].attackableness == Attackableness.SKIP )
end


local function die(event)
    event.actor:die()
end


local function watch(event)
    -- if did hit anything watch the cell for a beat
    if not event.actor.dead then
        event.actor.world.grid:watchBeat(
            event.actor.pos,
            function(entity)
                if not event.actor.dead then
                    event.action = ActionState.Beneath
                    event.actor:executeAttack(event.action)
                end
            end
        )
    end
end


-- apply retouchers
local Retouchers = require '@retouchers.all'
local retouch = require('@retouchers.utils').retouch
Retouchers.Algos.simple(Projectile)
Retouchers.Reorient.onActionSuccess(Projectile)
Retouchers.Attackableness.no(Projectile)
Retouchers.Skip.emptyAttack(Projectile)
Retouchers.Skip.self(Projectile)
-- ...
retouch(Projectile, 'attack', { die, Ranks.HIGHEST })
retouch(Projectile, 'attack', { unattackableAfterCheck, Ranks.HIGHEST })
retouch(Projectile, 'move'  , { watch, Ranks.LOW })

local Basic = require '@action.handlers.basic'

local ProjectileAction = Action.fromHandlers(
    'ProjectileAction',
    {
        handlerUtils.applyHandler('attackBeneath'),
        Basic.Attack,
        Basic.Move
    }
)

local Target = require "@items.weapons.target"
local Piece = require "@items.weapons.piece"

function Projectile:getTargetsBeneath(direction)
    local coord = self.pos
    local entity = self.world.grid:getOneFromTopAt(coord)

    if entity == nil then
        return nil
    end

    local piece = Piece(coord, direction, false)
    local attackableness = entity:getAttackableness(entity)
    local target = Target(entity, piece, 1, attackableness)
    return target
end

function Projectile:getTargets(action)
    if action.state == ActionState.Beneath then
        -- return the real at this spot as the target
        return { self:getTargetsBeneath(action.direction) }
    else
        -- return the target as regular
        return { self:getTargetsDefault(action.direction) }
    end
end

-- define a new method with the logic. it is pretty simple
-- so decided to not use a decorator for now
-- TODO: refactor into a decorator and also check projectile resistances
function Projectile:attackBeneath(action)

    -- mark that we're doing the beneath phase
    action.state = ActionState.Beneath

    -- attack the real at our spot only if it looks 
    -- in the opposite to our movement direction
    local real = self.world.grid:getRealAt(self.pos)
    if 
        real ~= nil
        and real.orientation.x == -self.orientation.x 
        and real.orientation.y == -self.orientation.y
    then
        return self:executeAttack(action)
    end

    -- mark that we're back to the normal phase
    action.state = ActionState.Normal

    -- TODO: return projectile event
    return {}
end

-- override calculateAction. Return our custom action
function Projectile:calculateAction()
    local action = ProjectileAction()
    -- set the orientation right away since it won't change
    action.direction = self.orientation
    self.nextAction = action
end


return Projectile