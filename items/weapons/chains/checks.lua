local checks = {}

checks.stopIfEmpty = function(event)
    return #event.targets == 0
end

return checks