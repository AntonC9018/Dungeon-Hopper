-- TODO: This decorator has basically no purpose and should be transfromed into a function
local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Changes = require "render.changes"
local Move = require("logic.action.handlers.basic").Move

local Bumping = class('Bumping', Decorator)

local function bump(event)
    local pos, newPos = event.actor.pos, event.newPos
    if 
        newPos.x == pos.x
        and newPos.y == pos.y
    then
        event.actor.world:registerChange(event.actor, Changes.Bump)
    end
end

Bumping.affectedChains = {
    { "displace", { bump } }
}

return Bumping