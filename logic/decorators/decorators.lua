local Decorators = {}

Decorators.Acting = require "logic.decorators.acting"
Decorators.Attackable = require "logic.decorators.attackable"
Decorators.Attacking = require "logic.decorators.attacking"
Decorators.AttackableOnlyWhenNextToAttacker = require "logic.decorators.AttackableOnlyWhenNextToAttacker"
Decorators.Bumping = require "logic.decorators.bumping"
Decorators.Displaceable = require "logic.decorators.displaceable"
Decorators.Explodable = require "logic.decorators.explodable"
Decorators.General = require "logic.decorators.general"
Decorators.InvincibleAfterHit = require "logic.decorators.invincibleafterhit"
Decorators.Killable = require "logic.decorators.killable"
Decorators.Moving = require "logic.decorators.moving"
Decorators.Pushable = require "logic.decorators.pushable"
Decorators.PlayerControl = require "logic.decorators.playercontrol"
Decorators.Sequential = require "logic.decorators.sequential"
Decorators.Start = require "logic.decorators.start"
Decorators.Statused = require "logic.decorators.statused"
Decorators.Ticking = require "logic.decorators.ticking"
Decorators.WithHP = require "logic.decorators.withhp"

return Decorators