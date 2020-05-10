local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Attackableness = require 'logic.enums.attackableness'
local Ranks = require 'lib.chains.ranks'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 
local decorate = require('logic.decorators.decorate')
local Decorators = require "logic.decorators.decorators"
local Retouchers = require 'logic.retouchers.all'
local retouch = require('logic.retouchers.utils').retouch

local Projectile = class("Projectile", Entity)

-- select layer
Projectile.layer = Cell.Layers.projectile

-- Set up decorators
Decorators.Start(Projectile)
decorate(Projectile, Decorators.Acting)
decorate(Projectile, Decorators.Attacking)
decorate(Projectile, Decorators.Attackable)
decorate(Projectile, Decorators.Killable)
decorate(Projectile, Decorators.Moving)
decorate(Projectile, Decorators.Displaceable)
decorate(Projectile, Decorators.DynamicStats)
decorate(Projectile, Decorators.WithHP)
decorate(Projectile, require 'modules.test.decorators.proj')

-- apply retouchers
Retouchers.Algos.player(Projectile)
Retouchers.Attackableness.no(Projectile)
Retouchers.Skip.emptyAttack(Projectile)
Retouchers.Skip.self(Projectile)

-- select base stats
Projectile.baseModifiers = {
    move = {
        ignore = 1,
        distance = 1
    },
    proj = 1,
    hp = {
        amount = 2
    }   
}

local Basic = require 'logic.action.handlers.basic'

local ProjectileAction = Action.fromHandlers(
    'ProjectileAction',
    {
        handlerUtils.activateDecorator('ProjDec'),
        Basic.Attack,
        Basic.Move
    }
)
-- override calculateAction. Return our custom action
function Projectile:calculateAction()
    local action = ProjectileAction()
    -- set the orientation right away since it won't change
    action.direction = self.orientation
    self.nextAction = action
end


return Projectile