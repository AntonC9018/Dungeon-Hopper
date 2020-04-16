local Step = require "logic.action.sequence.step"

local Sequence = class('Sequence')


function Sequence:__construct(steps)
    self.steps = steps
    self.currentStepIndex = 1
end


function Sequence:setStep(index)
    local nextStepIndex = index % #self.steps + 1
    self.repet = 0
    return self.steps[self.currentStepIndex]
end


function Sequence:tick(event)

    -- get the current step
    local step = steps[self.currentStepIndex]

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

    self.currentStepIndex = nextStepIndex
end


function Sequence:getCurrentAction()
    return self.steps[self.currentStepIndex].ActionClass()
end

return Sequence