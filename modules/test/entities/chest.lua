
-- Class definition
local Chest = class('Chest', Entity)

Chest.layer = Layers.real

Decorators.Start(Chest)
decorate(Chest, Decorators.Killable)
decorate(Chest, Decorators.Interactable)
-- Retouchers.Attackableness.constant(Chest, Attackableness.IF_NEXT_TO)

local Init = require '.decorators.init'
decorate(Chest, Init)

local Options = require '@items.insides.options'
local Insides = require '.retouchers.insides'

Insides.setConstant(Chest, 
    { 
        id = Options.ITEM_FROM_POOL, 
        poolId = ItemSubpools.Weapons
        -- amount = 5
    }
)

-- add some test stuff
-- Insides.set(Chest,
--     {
--         { 50, { id = Options.ITEM, itemId = 1 } },
--         { 50, { id = Options.GOLD, amount = 5 } },
--         { 50, { id = Options.ENTITY, class = Chest } }
--     }
-- )
Insides.spawnOnDeath(Chest)

return Chest