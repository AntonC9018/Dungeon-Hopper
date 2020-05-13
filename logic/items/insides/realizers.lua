local Options = require '@items.insides.options'
local OptionRealizers = {}

OptionRealizers[Options.GOLD] = 
    function(actor, optionConfig)
        -- gold doesn't exist yet
        printf('Gold created. Amount of gold: %i', optionConfig.amount)
    end

OptionRealizers[Options.ENTITY] = 
    function(actor, optionConfig)
        -- instantiate the entity
        actor.world:create(optionConfig.class, actor.pos)
        -- will probably also need to pass some info to the view-model
    end

OptionRealizers[Options.ITEM] = 
    function(actor, optionConfig)
        actor.world:createDroppedItem(optionConfig.itemId, actor.pos)
    end

-- the item is drawn from the necessary pool at start
OptionRealizers[Options.ITEM_FROM_POOL] = 
    OptionRealizers[Options.ITEM]

return OptionRealizers