local StatTinker = require '@tinkers.stattinker'

-- TODO: store already used ones
return function(damage)
    return StatTinker({
        { StatTypes.Attack, 'damage', damage }
    })
end