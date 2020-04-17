
local utils = require "logic.decorators.utils" 
local Sequence = require "logic.action.sequence.sequence"

local Decorator = require 'logic.decorators.decorator'
local Sequential = class('Sequential', Decorator)

function Sequential:activate(actor)
    actor.nextAction = actor.sequence:getCurrentAction()
end

function Sequential:__construct(instance)
    instance.sequence = Sequence(instance.sequenceSteps)
end

return Sequential