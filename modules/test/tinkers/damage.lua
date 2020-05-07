local StatTinker = require 'logic.tinkers.stattinker'
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes

-- TODO: store already used ones
return function(damage)
    return StatTinker({
        { StatTypes.Attack, 'damage', damage }
    })
end