-- these are for non-player reals

local applyHandler = function(nameApplyMethod)
    return function(outerEvent)
        local actor = outerEvent.entity
        local action = outerEvent.action

        local event = Event(actor, action)

        if event.propagate then    
            event = actor[nameApplyMethod](actor, action)
        end

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