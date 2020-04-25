local Changes = require "render.changes"
local HP = require "logic.hp.hp"
local Decorator = require "logic.decorators.decorator"

local WithHP = class("WithHP", Decorator)

function WithHP:activate(actor, damage)
    actor.hp:takeDamage(damage)
    actor.world:registerChange(actor, Changes.Hurt) 
end

function WithHP:__construct(instance)
    instance.hp = HP(instance.baseModifiers.hp.amount)
end

return WithHP