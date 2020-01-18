-- these are for player reals

local applyHandler = function(nameApplyMethod)
    return function(outerEvent)
        local actor = outerEvent.actor
        local action = outerEvent.action

        event = actor[nameApplyMethod](actor, action)  

        if event.propagate then
            -- previous action successful
            outerEvent.propagate = false
        end

        return outerEvent
    end
end

local AttackHandler = applyHandler("executeAttack")
local MoveHandler = applyHandler("executeMove")
local DigHandler = applyHandler("executeDig")

local Handlers = {}

Handlers.AttackHandler = AttackHandler
Handlers.MoveHandler = MoveHandler
Handlers.DigHandler = DigHandler

Hnadlers.applyHandler = applyHandler

return Handlers