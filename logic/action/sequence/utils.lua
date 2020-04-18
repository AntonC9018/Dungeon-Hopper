
local function traverseChainFunction(chain, stepNumber)
    return function(sequenceStep, event)
        local outerEvent = 
        
        chain:pass(outerEvent)

        if chain.propagate then
            return stepNumber
        end
        return sequenceStep.count
    end
end

return traverseChainFunction