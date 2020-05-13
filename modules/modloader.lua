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

-- for now just do this
decorate = require '@decorators.decorate'
Decorators = require '@decorators.decorators'

-- also make useful enums global
Attackableness = require '@enums.attackableness'
HowToReturn = require '@decorators.stats.howtoreturn'
Layers = require('world.cell').Layers

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

-- stuff for chains
Ranks = require 'lib.chains.ranks'
RankNumbers = require 'lib.chains.numbers'



-- now set up all mods
Mods = {}
MODULE_NAME = 'test'
Mods.Test = require 'modules.test.main'

print(ins(Mods, {depth = 3}))

-- require = req
