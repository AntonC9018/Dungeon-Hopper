

local checkApplyHandler = function(nameCheck, nameApplyMethod)
    return function(outerEvent)
        local actor = outerEvent.entity
        local action = outerEvent.action

        local event = Event(actor, action)

        actor.chains[nameCheck]:pass(event, Chain.checkPropagate)

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

local AttackHandler = checkApplyHandler("shouldAttack", "executeAttack")
local MoveHandler = checkApplyHandler("shouldMove", "executeMove")
local DigHandler = checkApplyHandler("shouldDig", "executeDig")
local SpecialHandler = checkApplyHandler("shouldSpecial", "executeSpecial")

local Handlers = {}

Handlers.AttackHandler = AttackHandler
Handlers.MoveHandler = MoveHandler
Handlers.DigHandler = DigHandler
Handlers.SpecialHandler = SpecialHandler

Hnadlers.checkApplyHandler = checkApplyHandler

return Handlers