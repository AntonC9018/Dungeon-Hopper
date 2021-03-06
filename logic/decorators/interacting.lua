local utils = require "@decorators.utils" 
local Changes = require "render.changes"
local Decorator = require '@decorators.decorator'
local Interactable = require '@decorators.interactable'

local Interacting = class('Interacting', Decorator)

-- interacting always takes place with the item right before the entity
local function getTarget(event)
    local grid = event.actor.world.grid
    event.target = grid:getRealAt(event.actor.pos + event.action.direction)
    event.propagate = event.target ~= nil
end

local function checkIsInteractable(event)
    event.propagate = event.target:isDecorated(Interactable)
end

local function interact(event)
    event.target.decorators.Interactable:activate(event.target, event.action)
end

Interacting.affectedChains = {
    { "checkInteract", 
        {
            getTarget,
            checkIsInteractable
        } 
    },
    { "interact", 
        { 
            interact
        } 
    }
}

Interacting.activate =
    utils.checkApplyCycle("checkInteract", "interact")


return Interacting