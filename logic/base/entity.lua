--
-- entity.lua
--
-- This is the base class for any entity in the game
local Decorators = require 'logic.decorators.decorators'
local PlayerAlgo = require 'logic.action.algorithms.player'
local GameObject = require 'logic.base.gameobject'
local None = require 'logic.action.actions.none'

local Entity = class("Entity", GameObject)

Entity.decorators = {}

-- Decorator stuff
function Entity:isDecorated(decorator)
    return self.decorators[class.name(decorator)] ~= nil
end

local activateDecorator = require("logic.base.utils").activateDecorator

-- shortcut functions
Entity.executeMove = 
    activateDecorator(Decorators.Moving)

Entity.executeAttack =
    activateDecorator(Decorators.Attacking)

Entity.beAttacked =
    activateDecorator(Decorators.Attackable)

Entity.bePushed =
    activateDecorator(Decorators.Pushable)

Entity.beStatused =
    activateDecorator(Decorators.Statused)

Entity.takeDamage =
    activateDecorator(Decorators.WithHP)

Entity.tick =
    activateDecorator(Decorators.Ticking)

Entity.die =
    activateDecorator(Decorators.Killable)

-- Setting the action type
local sequenceActivation = 
    activateDecorator(Decorators.Sequential)

function Entity:calculateAction()
    self.nextAction = None()
    sequenceActivation(self)
end

-- Executing the action
local actingActivation = 
    activateDecorator(Decorators.Acting)

function Entity:executeAction() 
    self.doingAction = true
    actingActivation(self)
    self.doingAction = false
    self.didAction = true
end
    
 

function Entity:isAttackableOnlyWhenNextToAttacker()
    return self:isDecorated(Decorators.AttackableOnlyWhenNextToAttacker)  
end

function Entity:isAttackable()
    return self:isDecorated(Decorators.Attackable)
end



-- fallback base modifiers
Entity.baseModifiers = {

    attack = {
        damage = 1,
        pierce = 1
    },

    move = {
        distance = 1
    },

    push = {
        distance = 1,
        power = 1
    },

    resistance = {
        armor = 0,
        maxDamage = math.huge,
        push = 1,
        pierce = 1
    },

    hp = 1
}


return Entity