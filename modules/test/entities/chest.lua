local Entity = require 'logic.base.entity'
local Cell = require 'world.cell'
local Decorators = require 'logic.decorators.decorators'
local decorate = require 'logic.decorators.decorate'
local Retouchers = require 'logic.retouchers.all'
local Attackableness = require 'logic.enums.attackableness'

-- Class definition
local Chest = class('Chest', Entity)

Chest.layer = Cell.Layers.real

Decorators.Start(Chest)
decorate(Chest, Decorators.Killable)
decorate(Chest, Decorators.Interactable)
-- Retouchers.Attackableness.constant(Chest, Attackableness.IF_NEXT_TO)

local Init = require 'modules.test.decorators.init'
decorate(Chest, Init)

local Options = require 'items.insides.options'
local Pools = require 'items.pool.test.map'
local Insides = require 'modules.test.retouchers.insides'

-- Insides.setConstant(Chest, 
--     { 
--         id = Options.ITEM_FROM_POOL, 
--         poolId = Pools.Weaponry 
--         -- amount = 5
--     }
-- )

-- add some test stuff
Insides.set(Chest,
    {
        { 50, { id = Options.ITEM, itemId = 1 } },
        { 50, { id = Options.GOLD, amount = 5 } },
        { 50, { id = Options.ENTITY, class = Chest } }
    }
)
Insides.spawnOnDeath(Chest)

return Chest