local Step = require "logic.action.sequence.step"

local Sequence = class('Sequence')
local initializeSteps = require("logic.action.sequence.stepfuncs").initializeSteps 

function Sequence:__construct(steps)
    self.steps = initializeSteps(steps)
    -- printf("Length of steps = %i", #self.steps) -- debug
    self.currentStepIndex = 1
end


function Sequence:setStep(index)
    local rest = index % (#self.steps + 1)
    if rest == 0 then
        self.currentStepIndex = 1
    else
        self.currentStepIndex = rest
    end
    self.repet = 0
    return self.steps[self.currentStepIndex]
end


function Sequence:tick(event)

    -- get the current step
    local step = self.steps[self.currentStepIndex]

    -- as the steps are stateless, we have to do
    -- this check outside the others
    if step.repet ~= nil then
        self.repet = self.repet + 1
        if self.repet <= step.repet then
            return
        end
    end

    local nextStepIndex = step:nextStep(event) 
        or (self.currentStepIndex + 1)    
        
        
    if nextStepIndex ~= self.currentStepIndex then
        local nextStep = self:setStep(nextStepIndex)
        step:exit(event)
        nextStep:enter(event)
    end
end


function Sequence:getCurrentAction()
    return self.steps[self.currentStepIndex].ActionClass()
end

function Sequence:getMovs(...)
    return self.steps[self.currentStepIndex].getMovs(...)
end

return Sequence