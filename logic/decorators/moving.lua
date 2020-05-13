local utils = require "@decorators.utils" 
local Changes = require "render.changes"
local Decorator = require '@decorators.decorator'
local Move = require '@action.effects.move'

local Moving = class('Moving', Decorator)

local function getBase(event)
    event.move = event.actor:getStat(StatTypes.Move)
    event.move.direction = event.action.direction
end

local function displace(event)
    event.actor:displace(event.move)  
end

Moving.affectedChains = {
    { "getMove", 
        { 
            getBase 
        }
    },
    { "move", 
        { 
            displace, 
            utils.regChangeFunc(Changes.Move) 
        } 
    }
}

Moving.activate = 
    utils.checkApplyCycle("getMove", "move")
    

return Moving