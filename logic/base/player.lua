local Entity = require "logic.base.entity"
local Decorators = require "logic.decorators.decorators"
local Combos = require "logic.decorators.combos"
local PlayerAlgo = require "logic.action.algorithms.player"
local Cell = require "world.cell"
local activateDecorator = require("logic.base.utils").activateDecorator

local Player = class("Player", Entity)

Player.layer = Cell.Layers.player

-- set up all decorators
Combos.Player(Player)

Player.generateAction = 
    activateDecorator(Decorators.PlayerControl)
    
-- Add the handlers to chain
Player.chainTemplate:addHandler(
    "getAttack", 
    function(event)
        if #event.targets == 0 then
            event.propagate = false    
        end
    end
)
Player.chainTemplate:addHandler(
    "getDig",
    function(event)
        if #event.targets == 0 then
            event.propagate = false    
        end
    end
)

-- TODO: add moving check

-- TODO: Call the character Candace
return Player