local utils = require '@retouchers.utils'
local Changes = require 'render.changes'
local State = require 'modules.test.enums.pressed'

local trap = {}

local function changeState(event)
    event.actor.state = State.PRESSED
end

trap.bePushedOnBounce = function(Trap)
    utils.retouch(Trap, 'bounce', changeState)
end


local function unpress(event)
    local actor = event.actor
    
    local nextState =
        actor.world.grid:getRealAt(actor.pos) ~= nil
        and State.PRESSED
        or State.UNPRESSED
    
    if actor.state ~= nextState then
        actor.world:registerChange(actor, Changes.JustState)
    end
end

trap.tickUnpress = function(Trap)
    utils.retouch(Trap, 'tick', unpress)
end

return trap