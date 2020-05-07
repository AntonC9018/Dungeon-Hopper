local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Attackableness = require 'logic.enums.attackableness'
local Ranks = require 'lib.chains.ranks'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 

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
local decorate = require ("logic.decorators.decorator").decorate
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


local function unattackableAfterCheck(event)
    event.propagate = not
        ( event.targets[1].attackableness == Attackableness.NO 
          or event.targets[1].attackableness == Attackableness.SKIP )
end

local function die(event)
    event.actor:die()
end

-- apply retouchers
local Retouchers = require 'logic.retouchers.all'
local retouch = require('logic.retouchers.utils').retouch
Retouchers.Algos.player(Projectile)
Retouchers.Reorient.onActionSuccess(Projectile)
Retouchers.Attackableness.no(Projectile)
Retouchers.Skip.emptyAttack(Projectile)
Retouchers.Skip.self(Projectile)
-- ...
retouch(Projectile, 'attack', { die, Ranks.HIGHEST })
retouch(Projectile, 'attack', { unattackableAfterCheck, Ranks.HIGHEST })


local ProjectileAction = Action.fromHandlers(
    'ProjectileAction',
    handlerUtils.applyHandler('executeProjectile')
)

-- return the real at this spot as the target
function Projectile:getTargets(action)
    local target = self:getTargetsDefault( Vec(0, 0) )
    if target ~= nil then
        target.piece.dir = action.direction
    end
    return { target }
end

-- define a new method with the logic. it is pretty simple
-- so decided to not use a decorator for now
-- TODO: refactor into a decorator and also check projectile resistances
function Projectile:executeProjectile(action)

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

    -- else move and then try to attack
    local moveEvent = self:executeMove(action)
    local attackEvent = self:executeAttack(action)

    -- if did hit anything watch the cell for a beat
    if not self.dead then
        self.world.grid:watchBeat(
            self.pos,
            function(entity)
                if not self.dead then
                    -- if hit a projectile, just destroy both
                    if entity.layer == Cell.Layers.projectile then
                        self:die()
                        entity:die()
                    else
                        self:executeAttack(action)
                    end
                end
            end
        )
    end

    -- TODO: return projectile event
    return attackEvent
end

-- override calculateAction. Return our custom action
function Projectile:calculateAction()
    local action = ProjectileAction()
    -- set the orientation right away since it won't change
    action.direction = self.orientation
    self.nextAction = action
end


return Projectile