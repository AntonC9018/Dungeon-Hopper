
local utils = require "utils" 
local Sequence = require "logic.action.sequence.sequence"


local function calculateAction(actor)
    actor.nextAction = actor.sequence:nextAction()
end


local Sequential = function(entityClass, steps)
    entityClass.calculateAction = calculateAction

    entityClass.__emitter:on("create", 
    
        function(instance)
            instance.sequence = Sequence(steps)
        end
    )

    table.insert(entityClass.decorators, Sequential)
end


return Sequential