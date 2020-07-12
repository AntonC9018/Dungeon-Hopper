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
    entity.class_id = entityClassId 
    Entities[entity.class_id] = entity
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

-- make the action class global
Action = require '@action.action'


-- for now, define some pools here
local Pools = require 'game.pools'

-- define some subpools
Pools.registerRootPool('e', Entities, Pools.poolTypes.infinite)
Pools.registerSubpool('e', 'z1')
Pools.registerSubpool('e.z1', 'f1')
Pools.registerSubpool('e.z1.*', 'enemy')
Pools.registerSubpool('e.z1.*', 'wall')
Pools.registerRootPool('i', Items, Pools.poolTypes.normal)
Pools.registerSubpool('i', 'common')
Pools.registerSubpool('i', 'rare')
Pools.registerSubpool('i.*', 'weapon')
Pools.registerSubpool('i.*', 'trinket')

-- now set up all mods
require 'modules.modloader'