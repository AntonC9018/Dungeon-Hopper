
local HP = require "logic.hp.hp"
local Decorator = require "logic.decorators.decorator"

local WithHP = class("WithHP", Decorator)

function WithHP:activate(actor, damage)
    actor.hp:takeDamage(damage)
end

function WithHP:__construct(instance)
    instance.hp = HP(instance.baseModifiers.hp)
end

return WithHP