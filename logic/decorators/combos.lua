local Decorators = require "logic.decorators.decorators"
local Decorator = require "logic.decorators.decorator"
local decorate = Decorator.decorate
local PlayerAlgo = require "logic.action.algorithms.player"
local GeneralAlgo = require "logic.action.algorithms.general"

local Combos = {}

Combos.BasicEnemy = function(Enemy)
    Decorators.Start(Enemy)
    decorate(Enemy, Decorators.Acting)
    decorate(Enemy, Decorators.Sequential)
    decorate(Enemy, Decorators.Killable)
    decorate(Enemy, Decorators.Ticking)
    decorate(Enemy, Decorators.Attackable)
    decorate(Enemy, Decorators.Attacking)
    decorate(Enemy, Decorators.Bumping)
    decorate(Enemy, Decorators.Explodable)
    decorate(Enemy, Decorators.Moving)
    decorate(Enemy, Decorators.Pushable)
    decorate(Enemy, Decorators.Statused)
    decorate(Enemy, Decorators.WithHP)
    decorate(Enemy, Decorators.Displaceable)
    decorate(Enemy, Decorators.DynamicStats)
    Enemy.chainTemplate:addHandler('action', GeneralAlgo)
end

Combos.Player = function(Player)
    Decorators.Start(Player)
    decorate(Player, Decorators.Ticking)
    decorate(Player, Decorators.Killable)
    decorate(Player, Decorators.Acting)    
    decorate(Player, Decorators.Attackable)
    decorate(Player, Decorators.Attacking) 
    decorate(Player, Decorators.Bumping)  
    decorate(Player, Decorators.Explodable)
    decorate(Player, Decorators.Moving)  
    decorate(Player, Decorators.Pushable) 
    decorate(Player, Decorators.Statused) 
    decorate(Player, Decorators.InvincibleAfterHit)
    decorate(Player, Decorators.PlayerControl)
    decorate(Player, Decorators.WithHP)
    decorate(Player, Decorators.Displaceable)
    decorate(Player, Decorators.Digging)
    decorate(Player, Decorators.DynamicStats)
    Player.chainTemplate:addHandler('action', PlayerAlgo)
end

return Combos