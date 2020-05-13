local utils = require "@items.weapons.chains.utils"
local filters = require "@items.weapons.chains.filters"
local checks = require "@items.weapons.chains.checks"
-- Check if hitting AttackableOnlyWhenNextToAttacker, 
-- without being next to any (return nothing in this case) ->
-- -> Check unreachableness (eliminate unreachable ones) ->
-- -> Eliminate targets with Attackableness.IS_CLOSE that aren't close and those with Attackableness.NO ->
-- -> Take the first available


local function checkStop(event)
    return Chain.checkPropagate(event) or checks.stopIfEmpty(event)
end

-- define a general chain
local chain = Chain(
    {
        utils.filter(filters.Nil),
        utils.nextToAny,
        utils.unreachable,
        utils.filter(filters.Unattackable),
        utils.eliminate,
        utils.takeFirst
    }
)

return {
    chain = chain,
    check = checkStop
}
