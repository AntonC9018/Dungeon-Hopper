local Entity = require "entity"
local Decorators = require "decorators.decorators"
local PlayerAlgo = require "logic.action.algorithms.player"


local Player = class("Player", Entity)

Decorators.Start     (Player)

Decorators.Acting    (Player)
Player.chainTemplate:addHandler("action", PlayerAlgo)
Decorators.Attackable(Player)
Decorators.Attacking (Player)
Decorators.Bumping   (Player)
Decorators.Explodable(Player)
Decorators.InvincibleAfterHit(Player)
Decorators.Moving    (Player)
Decorators.Pushable  (Player)
Decorators.Statused  (Player)

-- TODO: Call the character Candace