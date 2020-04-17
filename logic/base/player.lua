local Entity = require "logic.base.entity"
local Decorators = require "logic.decorators.decorators"
local decorate = require ("logic.decorators.decorator").decorate
local PlayerAlgo = require "logic.action.algorithms.player"
local Cell = require "world.cell"
local activateDecorator = require("logic.base.utils").activateDecorator

local Player = class("Player", Entity)


Player.layer = Cell.Layers.player

Decorators.Start(Player)
decorate(Player, Decorators.Ticking)
decorate(Player, Decorators.Killable)
decorate(Player, Decorators.Acting)    
Player.chainTemplate:addHandler("action", PlayerAlgo)
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



Player.generateAction = 
    activateDecorator(Decorators.PlayerControl)
    

-- TODO: Call the character Candace
return Player