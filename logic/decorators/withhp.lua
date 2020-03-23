
local HP = require "logic.hp.hp"


function WithHP:activate(actor, damage)
    actor.hp:takeDamage(damage)
end

function WithHP:__construct(instance)
    instance.hp = HP(instance.baseModifiers.hp)
end

return WithHP