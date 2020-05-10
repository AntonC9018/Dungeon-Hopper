
local decorate = require ("logic.decorators.decorator").decorate
local Decorators = require "logic.decorators.decorators"
local Retouchers = require 'logic.retouchers.all'
local retouch = require('logic.retouchers.utils').retouch
local Bouncing = require 'modules.test.decorators.bouncing'
local TrapRetouchers = require 'modules.test.retouchers.trap'


local combos = {}


combos.Trap = function(Trap)
    Decorators.Start(Trap)
    decorate(Trap, Decorators.WithHP)
    decorate(Trap, Decorators.Ticking)
    decorate(Trap, Decorators.Attackable)
    decorate(Trap, Decorators.Acting)
    decorate(Trap, Decorators.DynamicStats)

    -- apply our custom decorator

    -- use the player algo
    Retouchers.Algos.player(Trap)
    Retouchers.Attackableness.no(Trap)
end


combos.BounceTrap = function(Trap)
    combos.Trap(Trap)
    decorate(Trap, Bouncing)    
    TrapRetouchers.bePushedOnBounce(Trap)
    TrapRetouchers.tickUnpress(Trap)

end


combos.Projectile = function(Projectile)
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
end


combos.EnvObject = function(EnvObject)

    Decorators.Start(EnvObject)
    decorate(EnvObject, Decorators.Attackable)
    decorate(EnvObject, Decorators.Killable)
    decorate(EnvObject, Decorators.Pushable)
    decorate(EnvObject, Decorators.Displaceable)
    decorate(EnvObject, Decorators.DynamicStats)
    decorate(EnvObject, Decorators.WithHP)

    Retouchers.Attackableness.constant(EnvObject, Attackableness.IF_NEXT_TO)
end


combos.Wall = function(Wall)
    
    Decorators.Start(Wall)
    decorate(Wall, Decorators.Diggable)
    decorate(Wall, Decorators.WithHP)
    decorate(Wall, Decorators.Attackable)
    decorate(Wall, Decorators.Killable)
    decorate(Wall, Decorators.DynamicStats)

    local Attackableness = require 'logic.retouchers.attackableness'
    Attackableness.no(Wall)
end


return combos