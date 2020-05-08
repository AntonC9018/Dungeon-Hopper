local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Attackableness = require 'logic.enums.attackableness'
local Ranks = require 'lib.chains.ranks'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 

local Projectile = class("Projectile", Entity)

-- select layer
Projectile.layer = Cell.Layers.projectile

-- select base stats
Projectile.baseModifiers = {
    move = {
        ignore = 1,
        distance = 1
    },
    proj = 1,
    hp = {
        amount = 2
    }   
}

local Basic = require 'logic.action.handlers.basic'

local ProjectileAction = Action.fromHandlers(
    'ProjectileAction',
    {
        handlerUtils.activateDecorator('ProjDec'),
        Basic.Attack,
        Basic.Move
    }
)
-- override calculateAction. Return our custom action
function Projectile:calculateAction()
    local action = ProjectileAction()
    -- set the orientation right away since it won't change
    action.direction = self.orientation
    self.nextAction = action
end


return Projectile