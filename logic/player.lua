local Entity = require "entity"
local Decorators = require "decorators.decorators"


local Player = class("Player", Entity)

Decorators.Attackable.decorate(Player)
Decorators.Explodable.decorate(Player)
Decorators.Pushable  .decorate(Player)
Decorators.Attacking .decorate(Player)
Decorators.Moving    .decorate(Player)
Decorators.Statused  .decorate(Player)
-- Decorators.Real      .decorate(Player)

-- TODO: Call the character Candace