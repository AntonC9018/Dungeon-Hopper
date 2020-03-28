local Entity = require "entity"
local Decorators = require "decorators.decorators"
local PlayerAlgo = require "logic.action.algorithms.player"


local Player = class("Player", Entity)

Decorators.Start(Player)
Decorators.Acting    .decorate(Player)
Player.chainTemplate:addHandler("action", PlayerAlgo)
Decorators.Attackable.decorate(Player)
Decorators.Attacking .decorate(Player)
Decorators.Bumping   .decorate(Player)
Decorators.Explodable.decorate(Player)
Decorators.InvincibleAfterHit.decorate(Player)
Decorators.Moving    .decorate(Player)
Decorators.Pushable  .decorate(Player)
Decorators.Statused  .decorate(Player)

-- TODO: Call the character Candace