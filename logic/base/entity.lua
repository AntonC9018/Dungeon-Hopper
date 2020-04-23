--
-- entity.lua
--
-- This is the base class for any entity in the game
local Decorators = require 'logic.decorators.decorators'
local PlayerAlgo = require 'logic.action.algorithms.player'
local GameObject = require 'logic.base.gameobject'
local None = require 'logic.action.actions.none'
local Attackableness = require 'logic.enums.attackableness'

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

Entity.displace = 
    activateDecorator(Decorators.Displaceable)


function Entity:getAttackableness(attacker)
    local attackable = self.decorators.Attackable

    -- if has attackable decorator
    if attackable then
        -- call their method
        return attackable:getAttackableness(self, attacker)
    end
    -- can't be attacked
    return Attackableness.NO
end


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


-- TODO: implement
function Entity:getWeapon()
    return nil
end

-- now, methods that access grid on world
-- these methods are overridable
function Entity:getTargets(action)

    local weapon = self:getWeapon()

    if weapon ~= nil then
        return weapon:hitsFromAction(actor, action)
    end

    local coord = self.pos + action.direction
    local real = self.world.grid:getRealAt(coord)

    if real == nil then
        return nil
    end

    local piece = Piece(coord, action.direction, false)
    local attackableness = real:getAttackableness(self)
    local target = Target(real, piece, 1, attackableness)
    return { target }
end


return Entity