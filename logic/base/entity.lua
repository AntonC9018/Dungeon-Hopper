--
-- entity.lua
--
-- This is the base class for any entity in the game
local Decorators = require 'logic.decorators.decorators'
local PlayerAlgo = require 'logic.algos.player'
local GameObject = require 'logic.base.gameobject'
local None = require 'logic.action.actions.none'
local Attackableness = require 'logic.enums.attackableness'
local Changes = require 'render.changes'

local Entity = class("Entity", GameObject)

Entity.decorators = {}

-- Decorator stuff
function Entity:isDecorated(decorator)
    return self.decorators[class.name(decorator)] ~= nil
end

local activateDecorator = require("logic.base.utils").activateDecorator
local activateDecoratorCustom = require("logic.base.utils").activateDecoratorCustom
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

Entity.executeDig =
    activateDecorator(Decorators.Digging)

Entity.beDug =
    activateDecorator(Decorators.Diggable)

Entity.beBounced =
    activateDecorator(Decorators.Bounceable)

Entity.getStat =
    activateDecoratorCustom(Decorators.DynamicStats, 'getStat')

Entity.setStat = 
    activateDecoratorCustom(Decorators.DynamicStats, 'setStat')

Entity.addStat =
    activateDecoratorCustom(Decorators.DynamicStats, 'addStat')

    
function Entity:getAttackableness(attacker)
    local attackable = self.decorators.Attackable

    -- if has attackable decorator
    if attackable ~= nil then
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


function Entity:reorient(newOrientation)
    if 
        newOrientation.x ~= self.orientation.x
        or newOrientation.y ~= self.orientation.y 
    then
        self.orientation = newOrientation
        self.world:registerChange(self, Changes.Reorient)
    end
end


local Target = require "items.weapons.target"
local Piece = require "items.weapons.piece"

-- TODO: implement
function Entity:getWeapon()
    return self.weapon
end


local function getTargetsDefault(self, action)
    local coord = self.pos + action.direction
    local entity = self.world.grid:getOneFromTopAt(coord)

    if entity == nil then
        return nil
    end

    local piece = Piece(coord, action.direction, false)
    local attackableness = entity:getAttackableness(entity)
    local target = Target(entity, piece, 1, attackableness)
    return target
end

-- now, methods that access grid on world
-- these methods are overridable
function Entity:getTargets(action)

    local weapon = self:getWeapon()

    if weapon ~= nil then
        return weapon:getTargets(self, action)
    end

    local target = 
        getTargetsDefault(self, action)

    if 
        target ~= nil
        and target.attackableness ~= Attackableness.NO 
    then        
        return { target }
    end

    return {}    
end


function Entity:getDigTargets(action)

    -- TODO: add custom shovel functionality
    -- probably should implement shovels as weapons. 
    -- The logic would stay exactly the same, only the call to getAttackableness()
    -- will have to be changed to getDiggableness()
    -- another thing to consider...
    -- for now, just use the standart procedure for attacks

    local target = 
        getTargetsDefault(self, action)

    if 
        target ~= nil
        -- for now, just do this. in the future, change to diggableness
        and target.entity:isDecorated(Decorators.Diggable)
    then
        return { target }
    end

    return {}

end

return Entity