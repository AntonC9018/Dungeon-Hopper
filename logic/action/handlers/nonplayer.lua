-- these are for non-player reals

local checkApplyHandler = function(nameCheck, nameApplyMethod)
    return function(algoEvent)
        local actor = algoEvent.actor
        local action = algoEvent.action

        local internalEvent = Event(actor, action)

        actor.chains[nameCheck]:pass(internalEvent, Chain.checkPropagate)

        if internalEvent.propagate then    
            local resultEvent = actor[nameApplyMethod](actor, action)

            algoEvent.propagate = false
            algoEvent.success = true
            algoEvent.resultEvent = resultEvent
        end

        return algoEvent
    end
end

local AttackHandler = checkApplyHandler("shouldAttack", "executeAttack")
local MoveHandler = checkApplyHandler("shouldMove", "executeMove")
local DigHandler = checkApplyHandler("shouldDig", "executeDig")

local Handlers = {}

Handlers.Attack = AttackHandler
Handlers.Move = MoveHandler
Handlers.Dig = DigHandler

Handlers.checkApplyHandler = checkApplyHandler

return Handlers