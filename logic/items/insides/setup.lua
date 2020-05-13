local Options = require '@items.insides.options'
local InnardsSetup = {}

-- no pool so no setup needed
InnardsSetup[Options.GOLD] = nil
InnardsSetup[Options.ENTITY] = nil
InnardsSetup[Options.ITEM] = nil

-- need setup
InnardsSetup[Options.ITEM_FROM_POOL] = 
    function(actor, optionConfig)
        return {
            id = Options.ITEM_FROM_POOL,
            itemId = actor.world:getRandomItemFromPool(optionConfig.poolId)
        }
    end

return InnardsSetup