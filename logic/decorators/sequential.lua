
local utils = require "logic.decorators.utils" 
local Sequence = require "logic.action.sequence.sequence"

local Decorator = require 'logic.decorators.decorator'
local Sequential = class('Sequential', Decorator)

function Sequential:activate(actor)
    actor.nextAction = actor.sequence:getCurrentAction()
end

function Sequential:__construct(instance)
    local sequence = Sequence(instance.sequenceSteps)
    instance.sequence = sequence
    
    instance.chains.tick:addHandler(
        function(event)
            sequence:tick(event)
        end
    )
end

return Sequential