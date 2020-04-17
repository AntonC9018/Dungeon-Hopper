
local Decorator = require 'logic.decorators.decorator'
local Ticking = class('Ticking', Decorator)

local function resetBasic(event) 
    local actor = event.actor

    actor.didAction = false
    actor.doingAction = false
    actor.nextAction = nil
    actor.enclosingEvent = nil

    -- refresh history
end

Ticking.affectedChains = {
    { "tick", { resetBasic } }
}

function Ticking:activate(actor)
    local event = Event(actor)
    actor.chains.tick:pass(event)
end


return Ticking