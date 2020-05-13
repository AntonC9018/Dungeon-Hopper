local Step = require "@sequence.step"

local Sequence = class('Sequence')
local initializeSteps = require "@sequence.init"

function Sequence:__construct(steps)
    self.steps = initializeSteps(steps)
    -- printf("Length of steps = %i", #self.steps) -- debug
    self.currentStepIndex = 1
    self.repet = 0
end


function Sequence:setStep(index)
    local remainder = index % (#self.steps + 1)
    if remainder == 0 then
        self.currentStepIndex = 1
    else
        self.currentStepIndex = remainder
    end
    self.repet = 0
    return self.steps[self.currentStepIndex]
end


function Sequence:tick(tickEvent)

    -- get the current step
    local step = self.steps[self.currentStepIndex]

    -- as the steps are stateless, we have to do
    -- this check outside the others
    if step.repet ~= nil then
        self.repet = self.repet + 1
        if self.repet < step.repet then
            return
        end
    end

    local nextStepIndex = step:nextStep(tickEvent) 
        or (self.currentStepIndex + 1)    
        
        
    if nextStepIndex ~= self.currentStepIndex then
        local nextStep = self:setStep(nextStepIndex)
        step:exit(tickEvent)
        nextStep:enter(tickEvent)
    end
end


function Sequence:getCurrentAction()
    return self.steps[self.currentStepIndex].ActionClass()
end

function Sequence:getMovs(...)
    return self.steps[self.currentStepIndex].getMovs(...)
end

return Sequence