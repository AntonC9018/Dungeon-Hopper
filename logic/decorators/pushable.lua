local utils = require "@decorators.utils" 
local Changes = require "render.changes"
local Decorator = require '@decorators.decorator'

local Pushable = class('Pushable', Decorator)


local setBase = function(event)
    event.resistance = event.actor:getStat(StatTypes.PushRes)
end

local checkPush = function(event)
    local push = event.action.push
    event.propagate = 
        event.resistance:get(push.source) <= push.power
end

local executePush = function(event)
    local move = event.action.push:toMove(event.action.direction)
    -- actor is the thing being pushed
    event.actor:displace(move)  
end


Pushable.affectedChains = {
    { "checkPush", 
        { 
            setBase, 
            checkPush 
        } 
    },
    { "executePush", 
        { 
            executePush, 
            utils.regChangeFunc(Changes.Pushed) 
        } 
    }
}

Pushable.activate = 
    utils.checkApplyCycle("checkPush", "executePush")
 

return Pushable