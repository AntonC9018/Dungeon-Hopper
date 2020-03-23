
local HP = require "logic.hp.hp"


local function takeDamage(actor, damage)
    actor.hp:takeDamage(damage)
end


local WithHP = function(entityClass)
    entityClass.takeDamage = takeDamage

    entityClass.__emitter:on("create", 
    
        function(instance)
            instance.hp = HP(instance.baseModifiers.hp)
        end
    )

    table.insert(entityClass.decorators, WithHP)
end


return WithHP