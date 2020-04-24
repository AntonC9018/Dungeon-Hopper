local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"

local Decorator = require 'logic.decorators.decorator'
local Bounceable = class('Bounceable', Decorator)


-- TODO: implement these methods
-- probably use resistance classes for each type of the decorator for this
local checkBounce = function(event)
    if event.action.bounce.power < event.actor.baseModifiers.resistance.bounce then
        event.propagate = false
    end
end

local executeBounce = function(event)
    local move = event.action.bounce:toMove(event.action.direction)
    -- actor is the thing being pushed
    event.displaceEvent = event.actor:displace(move)
end


Bounceable.affectedChains = {
    { "checkBounce", { checkBounce } },
    { "executeBounce", { executeBounce, utils.regChangeFunc(Changes.Pushed) } }
}

Bounceable.activate = 
    utils.checkApplyCycle("checkBounce", "executeBounce")
 

return Bounceable