local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"

local Decorator = require 'logic.decorators.decorator'
local Move = require 'logic.action.effects.move'

local Moving = class('Moving', Decorator)

local function getBaseMove(event)
    local move = Move(event.actor.baseModifiers.move, event.action.direction)
    event.move = move    
end

local function displace(event)    
    local move = event.move
    event.actor.world:displace(event.actor, event.move)     
end

Moving.affectedChains = {
    { "getMove", { getBaseMove }},
    { "move", { displace, utils.regChangeFunc(Changes.Move) } }
}

Moving.activate = 
    utils.checkApplyCycle("getMove", "move")
    

return Moving