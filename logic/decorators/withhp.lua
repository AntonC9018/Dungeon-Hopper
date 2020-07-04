local Changes = require "render.changes"
local HP = require "@hp.hp"
local Decorator = require "@decorators.decorator"

local WithHP = class("WithHP", Decorator)

function WithHP:activate(actor, damage)
    actor.hp:takeDamage(damage)
    actor:registerEvent(Changes.Hurt) 
end

function WithHP:__construct(instance)
    instance.hp = HP(instance.baseModifiers.hp.amount)
end

return WithHP