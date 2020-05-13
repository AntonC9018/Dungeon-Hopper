local Action = require '@action.action'
local handlerUtils = require '@action.handlers.utils'

local Projectile = class("Projectile", Entity)

-- select layer
Projectile.layer = Layers.projectile

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
Retouchers.Algos.simple(Projectile)
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

local Basic = require '@action.handlers.basic'

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