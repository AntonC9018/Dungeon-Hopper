-- Rework decorators as components

local Decorator = class("Decorator")

-- Basically, all decorators do right now is they add 
-- a bunch of handlers to chains / create new chains on instances

-- Store the list of affected chains here
Decorator.affectedChains = {}


function Decorator:__construct()
end

function Decorator:activate()
    assert(false, "Attempt to call unoverrided decorator activation for "..class.name(self).." decorator.")
end

return Decorator