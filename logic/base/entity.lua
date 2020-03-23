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
        function(self, action)
            local decorator = 
                self.decorators[name]
            
            if (decorator ~= nil)
                return decorator:activate(action)

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

Entity.executeAction = 
    activateDecorator(Decorators.Acting)
 

-- TODO: make these a bit more efficient
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