local Entity = require "logic.base.entity"
local Decorators = require "logic.decorators.decorators"
local Combos = require "logic.decorators.combos"
local PlayerAlgo = require "logic.algos.player"
local Cell = require "world.cell"
local activateDecorator = require("logic.base.utils").activateDecorator

local Player = class("Player", Entity)

Player.layer = Cell.Layers.player

-- set up all decorators
Combos.Player(Player)

Player.generateAction = 
    activateDecorator(Decorators.PlayerControl)
    

local Skip = require 'logic.retouchers.skip'
Skip.emptyAttack(Player)
Skip.emptyDig(Player)
local Reorient = require 'logic.retouchers.reorient'
Reorient.onActionSuccess(Player)
local Equip = require 'logic.retouchers.equip'
Equip.onDisplace(Player)


-- TODO: refactor into a decorator
function Player:equip(item)
    self.inventory:equip(item)
end
function Player:unequip(item)
    self.inventory:unequip(item)
end


Player.baseModifiers = {
    hp = {
        amount = 100
    },
    attack = {
        damage = 1,
        pierce = 2        
    }
}

-- TODO: Call the character Candace
return Player