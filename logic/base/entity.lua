--
-- entity.lua
--
-- This is the base class for any entity in the game
local Decorators = require '@decorators.decorators'
local decorate = require('@decorators.decorate')
local SimpleAlgo = require '@algos.simple'
local GameObject = require '@base.gameobject'
local None = require '@action.actions.none'
local Attackableness = require '@enums.attackableness'
local Changes = require 'render.changes'
local activateDecorator = require("@base.utils").activateDecorator
local activateDecoratorCustom = require("@base.utils").activateDecoratorCustom

local Entity = class("Entity", GameObject)

Entity.decorators = {}

-- Decorator stuff

-- just reapply saved decorators 
Entity.redecorate = function(from, entityClass)
    Decorators.Start(entityClass)
    for _, dec in ipairs(from.decoratorsList) do
        decorate(entityClass, dec)
    end
end

-- copy all chains
Entity.copyChains = function(from, entityClass)
    entityClass.chainTemplate = from.chainTemplate:clone()

    -- copy the decorators list
    entityClass.decoratorsList = {}
    for i, dec in ipairs(from.decoratorsList) do
        entityClass.decoratorsList[i] = dec
    end
end

function Entity:isDecorated(decorator)
    return self.decorators[class.name(decorator)] ~= nil
end

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
        self:registerEvent(Changes.Reorient)
    end
end


local Target = require "@items.weapons.target"
local Piece = require "@items.weapons.piece"


function Entity:getTargetsDefault(direction)
    local coord = self.pos + direction
    local entity = self.world.grid:getOneFromTopAt(coord)

    if entity == nil then
        return nil
    end

    local piece = Piece(coord, direction, false)
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
        self:getTargetsDefault(action.direction)

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
        self:getTargetsDefault(action.direction)

    if 
        target ~= nil
        -- for now, just do this. in the future, change to diggableness
        and target.entity:isDecorated(Decorators.Diggable)
    then
        return { target }
    end

    return {}

end


-- TODO: implement
function Entity:getWeapon()
    if self:isDecorated(Decorators.Inventory) then
        return self.inventory:get(Decorators.Inventory.Slots.weapon):get(1)
    end
end

--  for now, define the item interface here
-- TODO: refine
function Entity:equip(item)
    if self:isDecorated(Decorators.Inventory) then
        self.inventory:equip(item)
    else
        -- just tink the tinker
        item:beEquipped(self)
    end
end

function Entity:unequip(item)
    if self:isDecorated(Decorators.Inventory) then
        self.inventory:unequip(item)
    else
        -- untink + spawn
        item:beUnequipped(self)
    end
end

function Entity:removeItem(item)
    if self:isDecorated(Decorators.Inventory) then
        self.inventory:remove(item)
    else
        -- just untink the tinker
        item:beDestroyed(self)
    end
end

function Entity:dropExcess()
    if self:isDecorated(Decorators.Inventory) then
        self.inventory:dropExcess()
    end
end

return Entity