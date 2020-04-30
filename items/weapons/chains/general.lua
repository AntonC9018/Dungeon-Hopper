local utils = require "items.weapons.chains.utils"
-- Check if hitting AttackableOnlyWhenNextToAttacker, 
-- without being next to any (return nothing in this case) ->
-- -> Check unreachableness (eliminate unreachable ones) ->
-- -> Eliminate targets with Attackableness.IS_CLOSE that aren't close and those with Attackableness.NO ->
-- -> Take the first available


-- define a general chain
local chain = Chain(
    {
        utils.nextToAny,
        utils.filter,
        utils.unreachable,
        utils.eliminate,
        utils.takeFirst
    }
)

return {
    chain = chain,
    check = utils.checkStop
}
