
local utils = require "logic.decorators.utils" 
local Sequence = require "logic.sequence.sequence"

local Decorator = require 'logic.decorators.decorator'
local Sequential = class('Sequential', Decorator)

function Sequential:activate(actor)
    actor.nextAction = actor.sequence:getCurrentAction()
end

function Sequential:__construct(instance)
    local sequence = Sequence(instance.sequenceSteps)
    instance.sequence = sequence
    
    -- TODO: transform this into an emitter on the tick decorator
    instance.chains.tick:addHandler(
        function(event)
            print(class.name(event.actor))
            sequence:tick(event)
        end
    )
end

return Sequential