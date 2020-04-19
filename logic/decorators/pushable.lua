local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"

local Decorator = require 'logic.decorators.decorator'
local Pushable = class('Pushable', Decorator)


-- TODO: implement these methods
local checkPush = function(event)
    if event.action.push.power < event.actor.baseModifiers.resistance.push then
        event.propagate = false
    end
end

local executePush = function(event)
    local move = event.action.push:toMove(event.action.direction)
    -- actor is the thing being pushed
    event.actor.world:displace(event.actor, move)    
end


Pushable.affectedChains = {
    { "checkPush", { checkPush } },
    { "executePush", { executePush, utils.regChangeFunc(Changes.Pushed) } }
}

Pushable.activate = 
    utils.checkApplyCycle("checkPush", "executePush")
 

return Pushable