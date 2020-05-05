local Decorators = {}

Decorators.Acting = require "logic.decorators.acting"
Decorators.Attackable = require "logic.decorators.attackable"
Decorators.Attacking = require "logic.decorators.attacking"
Decorators.Displaceable = require "logic.decorators.displaceable"
Decorators.Diggable = require "logic.decorators.diggable"
Decorators.Digging = require "logic.decorators.digging"
Decorators.DynamicStats = require "logic.decorators.dynamicstats"
Decorators.General = require "logic.decorators.general"
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