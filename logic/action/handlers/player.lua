-- these are for player reals

local applyHandler = function(nameApplyMethod)
    return function(algoEvent)
        local actor = algoEvent.actor
        local action = algoEvent.action

        -- printf("In algoevent calling method %s", nameApplyMethod) -- debug

        local resultEvent = actor[nameApplyMethod](actor, action)  

        if resultEvent.propagate then
            -- previous action successful
            algoEvent.propagate = false
            algoEvent.success = true
            algoEvent.resultEvent = resultEvent
        end

        return algoEvent
    end
end

local AttackHandler = applyHandler("executeAttack")
local MoveHandler = applyHandler("executeMove")
local DigHandler = applyHandler("executeDig")

local Handlers = {}

Handlers.Attack = AttackHandler
Handlers.Move = MoveHandler
Handlers.Dig = DigHandler

Handlers.applyHandler = applyHandler

return Handlers