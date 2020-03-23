local utils = require "utils" 

local Decorator = require 'decorator'
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