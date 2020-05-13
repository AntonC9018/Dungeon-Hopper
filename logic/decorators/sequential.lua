
local utils = require "@decorators.utils" 
local Sequence = require "@sequence.sequence"
local Decorator = require '@decorators.decorator'

local Sequential = class('Sequential', Decorator)

function Sequential:activate(actor)
    actor.nextAction = actor.sequence:getCurrentAction()
end

function Sequential:__construct(instance)
    local sequence = Sequence(instance.sequenceSteps)
    instance.sequence = sequence
    
    -- TODO: transform this into an emitter on the tick decorator probably
    instance.chains.tick:addHandler(
        function(event)
            if event.actor.nextAction ~= nil then
                sequence:tick(event)
            end
        end
    )
end

return Sequential