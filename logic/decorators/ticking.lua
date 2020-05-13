
local Decorator = require '@decorators.decorator'
local Ticking = class('Ticking', Decorator)

local function resetBasic(event) 
    local actor = event.actor


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