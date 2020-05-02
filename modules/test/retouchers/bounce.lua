local utils = require 'logic.retouchers.utils'
local Phases = require 'world.phases'
local AttackAction = require 'logic.action.actions.attack'
local Ranks = require 'lib.chains.ranks'


local bounce = {}


local function redirectAfterBounce(event)
    if event.actor.world.phase == Phases.Traps then
        event.actor:reorient(event.move.direction)
    end
end

bounce.redirectAfter = function(entityClass)
    utils.retouch(entityClass, 'displace', redirectAfterBounce)
end


local function redoAttackMove(event)
    if event.actor.world.phase == Phases.Trap then
        local attackAction = AttackAction()
        attackAction:setDirection(event.move.direction)
        event.actor:executeAttack(attackAction)
    end
end

bounce.redoAttackAfter = function(entityClass)
    utils.retouch(entityClass, 'displace', { redoAttackMove, Ranks.LOW })
end


return bounce