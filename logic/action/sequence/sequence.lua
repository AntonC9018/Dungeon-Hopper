

local Sequence = class('Sequence')


function Sequence:__construct(steps)

    self.steps = steps

    self.currentStepCount = 1

end


-- return the next action
function Sequence:nextAction(event)

    -- get the current step
    local step = steps[currentStepCount]

    local success = step:checkSuccess(event)

    local nextStepCount

    if success then
        nextStepCount = step:success()
    
    else
        nextStepCount = step:failure()
    end

    
    
end