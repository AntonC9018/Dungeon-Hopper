--
-- entity.lua
--
-- This is the base class for any entity in the game
local Decorators = require 'decorators.decorators'

-- Decorator stuff
function Entity:isDecorated(decorator)
    return self.decorators[class.name(decorator)] ~= nil
end

function activateDecorator(decorator)
    local name = class.name(decorator)
    return 
        function(self, ...)
            local decorator = 
                self.decorators[name]
            
            if (decorator ~= nil)
                return decorator:activate(...)

            return nil
        end
end

-- shortcut functions
Entity.executeMove = 
    activateDecorator(Decorators.Moving)

Entity.executeAttack =
    activateDecorator(Decorators.Attacking)

Entity:beAttacked =
    activateDecorator(Decorators.Attackable)

Entity:bePushed =
    activateDecorator(Decorators.Pushable)

Entity:beStatused =
    activateDecorator(Decorators.Statused)

Entity:takeDamage =
    activateDecorator(Decorators.WithHP)

local actingActivation = 
    activateDecorator(Decorators.Acting)

function Entity:executeAction(event) 
    self.doingAction = true
    actingActivation(self, event)
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

    hp = 0
}


return Entity