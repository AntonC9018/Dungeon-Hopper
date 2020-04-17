local utils = require "logic.decorators.utils" 

local Decorator = require 'logic.decorators.decorator'
local Move = require 'logic.action.effects.move'

local Moving = class('Moving', Decorator)

local function getBaseMove(action)
    local move = Move(action.actor.baseModifiers.move, action.direction)
    event.move = move    
end


local function displace(event)    
    local move = event.move
    event.actor.world:displace(event.actor, event.move)     
end

Moving.affectedChains = {
    { "getMove", { getBaseMove }},
    { "move", { displace } }
}

Moving.activate = 
    utils.checkApplyCycle("getMove", "move")
    

return Moving