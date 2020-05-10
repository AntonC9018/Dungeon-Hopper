local Entity = require "logic.base.entity"
local Decorators = require "logic.decorators.decorators"
local Combos = require "logic.decorators.combos"
local SimpleAlgo = require "logic.algos.simple"
local Cell = require "world.cell"
local activateDecorator = require("logic.base.utils").activateDecorator
local decorate = require('logic.decorators.decorate')
local Decorators = require "logic.decorators.decorators"
local Retouchers = require 'logic.retouchers.all'
local Attackableness = require 'logic.enums.attackableness'

local Player = class("Player", Entity)

Player.layer = Cell.Layers.player

-- set up all decorators
Player.generateAction = 
    activateDecorator(Decorators.PlayerControl)

Decorators.Start(Player)
decorate(Player, Decorators.Ticking)
decorate(Player, Decorators.Killable)
decorate(Player, Decorators.Acting)    
decorate(Player, Decorators.Attackable)
decorate(Player, Decorators.Attacking) 
decorate(Player, Decorators.Moving)  
decorate(Player, Decorators.Pushable) 
decorate(Player, Decorators.Statused) 
decorate(Player, Decorators.PlayerControl)
decorate(Player, Decorators.WithHP)
decorate(Player, Decorators.Displaceable)
decorate(Player, Decorators.Digging)
decorate(Player, Decorators.DynamicStats)
decorate(Player, Decorators.Inventory)
decorate(Player, Decorators.Interacting)

-- apply retouchers
Retouchers.Algos   .simple(Player)
Retouchers.Skip    .emptyAttack(Player)
Retouchers.Skip    .emptyDig(Player)
Retouchers.Reorient.onActionSuccess(Player)
Retouchers.Equip   .onDisplace(Player)

-- TODO: Call the character Candace
return Player