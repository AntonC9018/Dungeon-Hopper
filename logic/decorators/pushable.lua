local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Decorator = require 'logic.decorators.decorator'
local Pushable = class('Pushable', Decorator)


local setBase = function(event)
    event.resistance = event.actor:getStat(StatTypes.PushRes)
end

local checkPush = function(event)
    if event.action.push.power < event.resistance then
        event.propagate = false
    end
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