local Entity = require("Entity")
local Decorators = Entity.Decorators


local Player = class("Player", Entity)

Decorators.Attackable.decorate(Player)
Decorators.Explodable.decorate(Player)
Decorators.Pushable  .decorate(Player)
Decorators.Attacking .decorate(Player)
Decorators.Moving    .decorate(Player)
Decorators.Statused  .decorate(Player)
-- Decorators.Real      .decorate(Player)

