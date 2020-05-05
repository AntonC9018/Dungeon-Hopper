local Ranks = require 'lib.chains.ranks'
local RefTinker = require 'logic.tinkers.reftinker' 

local function stuckGenerator(tinker)
    return function(event)
        tinker:untink(event.actor)
        event.propagate = false
    end
end

local function generator(tinker)
    local stuck = { stuckGenerator(tinker), Ranks.HIGH }
    return {
        { 'attack',   stuck },
        { 'move',     stuck },
        { 'displace', stuck },
        { 'dig',      stuck }
    }
end

return RefTinker(generator)