local utils = require "items.weapons.chains.utils"
-- Check if hitting AttackableOnlyWhenNextToAttacker, 
-- without being next to any (return nothing in this case) ->
-- Return all targets

local function hitAll(event)
    -- we need to filter out NO-es
    event.targets = filterUnattackable(event.targets)
end

-- define the hit all chain
local chain = Chain(
    {
        utils.nextToAny,
        hitAll
    }
)

return {
    chain = chain,
    check = Chain.stopPropagate
}
