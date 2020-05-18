-- Define the following things globally:
--      1. StatTypes[name] -> id
--      2. Items[id] -> item
--      3. Entities[id] -> class
--      4. StatusTypes[name] -> id

-- set up local require
local req = require 

local PERIOD = ('.'):byte(1)
local AT     = ('@'):byte(1)

require = function(str)
    if str:byte(1) == PERIOD then
        return req('modules.'..MODULE_NAME..str)
    elseif str:byte(1) == AT then
        return req('logic.'..string.sub(str, 2))
    end

    return req(str)
end

-- make available globally some super essential stuff
ins = require('lib.inspect')
Emitter = require('lib.emitter')
Luaoop = require('lib.Luaoop')
class = Luaoop.class
Vec = require('lib.vec')
require('lib.utils')
Event = require('lib.chains.event')
Chain = require('lib.chains.schain')

-- stuff for chains
Ranks = require 'lib.chains.ranks'
RankNumbers = require 'lib.chains.numbers'
-- also make useful enums global
Attackableness = require '@enums.attackableness'
HowToReturn = require '@decorators.stats.howtoreturn'
Layers = require('world.cell').Layers


-- Set up global objects for stats, status effects and attack sources
local DynamicStats = require('@decorators.dynamicstats')
local Attackable = require('@decorators.attackable')
local Statused = require('@decorators.statused')

StatTypes = DynamicStats.StatTypes
StatusTypes = Statused.StatusTypes
AttackSourceTypes = Attackable.AttackSourceTypes
Items = {}
Entities = {}
InventorySlots = require('@decorators.inventory').Slots

-- for now, just reference the decorator
function registerStat(...)
    DynamicStats.registerStat(...)
end

function registerStatus(...)
    Statused.registerStatus(...)
end

function registerAttackSource(...)
    Attackable.registerAttackSource(...)
end

local itemId = 0

function registerItem(item)
    itemId = itemId + 1
    item.id = itemId
    Items[itemId] = item
end


local entityClassId = 0

function registerEntity(entity)
    entityClassId = entityClassId + 1
    entity.global_id = entityClassId 
    Entities[entity.global_id] = entity
end


-- Stuff with pools
local Pool = require '@items.pool.pool'
local Record = require '@items.pool.record'
local InfPool = require '@items.pool.infinite.pool'
local InfRecord = require '@items.pool.infinite.record'

local itemPoolConfig = {
    subpools = {}
}
local itemPoolId = 2
local itemPoolObjectMap = { itemPoolConfig }

ItemSubpools = {
    Global = 1
}

function registerItemSubpool(name, id, config)
    assert(id < itemPoolId, string.format("Trying to reference a non-existent subpool of id %i", id))
    local conf = { 
        ids = config or {},
        subpools = {}
    }
    table.insert(itemPoolObjectMap[id].subpools, conf)
    itemPoolObjectMap[itemPoolId] = conf
    ItemSubpools[name] = itemPoolId
    itemPoolId = itemPoolId + 1
end

function addSubpoolItem(id, itemId, mass, q)
    local entry = { id = itemId, mass = mass or 1 }
    table.insert(itemPoolObjectMap[id].ids, entry)
end

function instantiateItemPool(randomness)
    -- for now, put one item with mass of one in each thing
    local items = {}
    for i, _ in ipairs(Items) do
        items[i] = Record(i, 1, 1)
    end
    -- TODO: sort configs by id in ascending order
    return Pool(items, itemPoolConfig, randomness)
end

-- The exact same logic for entity pools
local entityPoolConfig = {
    subpools = {}
}
local entityPoolId = 2
local entityPoolObjectMap = { entityPoolConfig }

EntitySubpools = {
    Global = 1
}

function registerEntitySubpool(name, id, config)
    assert(id < entityPoolId, string.format("Trying to reference a non-existent subpool of id %i", id))
    local conf = { 
        ids = config or {}, 
        subpools = {} 
    }
    table.insert(entityPoolObjectMap[id].subpools, conf)
    entityPoolObjectMap[entityPoolId] = conf
    EntitySubpools[name] = entityPoolId
    entityPoolId = entityPoolId + 1
end

function addSubpoolEntity(id, entityId, mass)
    local entry = { id = entityId, mass = mass or 1 }
    table.insert(entityPoolObjectMap[id].ids, entry)
end

-- TODO: make it possible to mask the global config
-- to customize the output
-- alternatively, make people copy and reset the world's config on 
-- e.g. player selection so that this method is never called
-- but then the objects will have to be made global
function instantiateEntityPool(randomness)
    -- for now, put one entity with mass of one in each thing
    local entities = {}
    for i, _ in ipairs(Entities) do
        entities[i] = InfRecord(i, 1)
    end
    -- TODO: figure out how to provide a mapping from subpool id 
    -- to an actual subpool. For example:
    --  1. leave a reference to the pool in the config. while simple,
    --     it does not allow for new instances and is kinda hacky
    --  2. mark configs with ids. I actually very like this one. Then
    --     we'll just loop through the subpools of subpools and link
    --     everything in a new list. Seems ok.
    -- For now, if the id is not zero, and since we're using one level
    -- deep pools, the necessary pool can be referenced by indexing the
    -- subpools list with the subpool's global id.
    return InfPool(entities, entityPoolConfig, randomness)
end


-- for now just do this
decorate = require '@decorators.decorate'
Decorators = require '@decorators.decorators'

-- make essential base classes global
Entity = require '@base.entity'
copyChains = Entity.copyChains
GameObject = require '@base.gameobject'
Item = require '@items.item'

-- make essential retouchers global
Retouchers = require '@retouchers.all'
-- as well as their utils
retoucherUtils = require '@retouchers.utils'

-- make tinker classes global
-- Tinker = require '@tinkers.tinker'
-- StatTinker = require '@tinkers.stattinker'
-- RefTinker = require '@tinkers.reftinker'
-- RefStatTinker = require '@tinkers.refstattinker'
-- StoreTinker = require '@tinkers.storetinker'
-- StoreStatTinker = require '@tinkers.storestattinker'
-- -- as well as tinker utils
-- tinkerUtls = require '@tinkers.utils'

-- make the action class global
-- Action = require '@action.action'


-- for now, define some pools here
registerItemSubpool('Weapons',  1)
registerItemSubpool('Trinkets', 1)
registerItemSubpool('Armor',    1)
registerEntitySubpool('Enemies', 1)
registerEntitySubpool('Walls', 1)
registerEntitySubpool('Tiles', 1)

-- now set up all mods
Mods = {}
MODULE_NAME = 'test'
Mods.Test = require 'modules.test.main'