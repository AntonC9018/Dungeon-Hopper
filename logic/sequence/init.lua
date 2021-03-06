local Step = require "@sequence.step"

return function(configs)
    local steps = {}
    for i = 1, #configs do
        table.insert(steps, Step(configs[i]))
    end
    return steps
end