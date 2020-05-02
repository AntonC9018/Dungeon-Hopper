local utils = require "items.weapons.chains.utils"
local filters = require "items.weapons.chains.filters"
-- Check if hitting AttackableOnlyWhenNextToAttacker, 
-- without being next to any (return nothing in this case) ->
-- Return all targets


-- define the hit all chain
local chain = Chain(
    {
        utils.filter(filters.Nil),
        utils.filter(filters.LeaveAttackable),
        utils.nextToAny
    }
)

return {
    chain = chain,
    check = Chain.checkPropagate
}
