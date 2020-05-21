-- The format will be 
-- `i.rarity.category` for items and
-- `e.zone.floor` for entities
local Pool = require '@items.pool.pool'
local Record = require '@items.pool.record'
local InfPool = require '@items.pool.infinite.pool'
local InfRecord = require '@items.pool.infinite.record'


-- for now, the current stats are:
local current = {
    {
        1, 1
    },
    {
        1, 1
    }
}

-- provides a mapping of string of different depth levels
-- for example, in 'i.common', the root pool is i, which 
-- if the first entry in the depthMap is accessed. The depth 
-- level is also 1 and so the first entry is accessed yet again
-- it contains the count and the mappings. 
-- { count, { ..mappings.. } }
-- mappings just map strings to indeces that are then used 
-- to access the corresponding subpool or subpool config.
local depthMaps = {}

-- provides a mapping from the string name of the root pool
-- or its config to the index to it inside the rootConfigs list
-- and for the corresponding depthMap
local rootMap = {}

-- different pools may use either a InfPool or a normal Pool
-- an InfPool cannot be exhausted
local usedType = {}

-- The root pool configs are a bit different from the subpool
-- configs. Their 'ids' field indicates the items or entities 
-- that the pool will be comprised of. The config map is provided
-- on initialization. It would map the ids if elements of this list
-- to records, which are { id = ?, q = ?, mass = ? }. Otherwise,
-- the default records are used.
local rootConfigs = {}

-- local itemDepthMap = {
--     { 0, {} }, -- Rarity
--     { 0, {} } -- category
-- }

-- local entityDepthMap = {
--     { 0, {} }, -- Zone
--     { 0, {} }, -- Floor
--     { 0, {} }  -- layer ()
-- }


-- Basically, strings are mapped to indeces via the depthMap
-- Indeces are left unchanged
-- Tilda is mapped to the current zone/level/etc.
-- A star is left unchanged. It indicates all subpools.
local function preprocessString(str)
    local split = string.split(str, '.')
    split[1] = rootMap[ split[1] ]
    
    local mapTilda

    if current then
        mapTilda = current[ split[1] ]
    end

    local mapString = depthMaps[ split[1] ]

    for i = 2, #split do
        if split[i] == '*' then
            
        elseif split[i] == '~' then
            split[i] = mapTilda[i - 1]
        else
            local n = tonumber(split[i])

            if n == nil then
                if mapString[i - 1][2][ split[i] ] == nil then
                    error(split[i])
                end
                split[i] = mapString[i - 1][2][ split[i] ]            
            else
                split[i] = n
            end
        end
    end
    return split
end

local function updateToAll(current)
    if current[1] == nil then        
        return current.subpools
    end
    local result = {}
    for j = 1, #current do
        result[j] = updateToAll(current[j])
    end
    return result
end

local function updateToFirst(current, i)
    if current[1] == nil then
        return current.subpools[i]
    end
    local result = {}
    for j = 1, #current do
        result[j] = updateToFirst(current[j], i)
    end
    return result
end

local function toSubpool(current, split)
    for i = 2, #split do
        if split[i] == '*' then
            current = updateToAll(current)
        else
            current = updateToFirst(current, split[i])
        end
    end
    return current
end

local function getConfig(split)
    local root = rootConfigs[ split[1] ]
    return toSubpool(root, split)
end


local function register(subpool, config)
    if subpool[1] == nil then
        table.insert(subpool.subpools, { ids = config or {}, subpools = {} })
    else
        for _, s in ipairs(subpool) do
            register(s, table.deepClone(config))
        end
    end
end

local Pools = {}

Pools.poolTypes = {
    normal = { Pool, Record },
    infinite = { InfPool, InfRecord }
}

Pools.registerRootPool = function(name, items, poolType)
    assert(items ~= nil, 'You must provide the list of all items/etities/etc. ordered by ids for the root pool.')
    local index = #rootConfigs + 1
    rootMap[name] = index
    table.insert(rootConfigs, { items = items, subpools = {} })
    depthMaps[index] = {}

    usedType[index] = poolType
end

Pools.registerSubpool = function(str, name, config)
    local processed  = preprocessString(str)
    local parentPool = getConfig(processed)
    local depth      = #processed

    register(parentPool, config)

    if depthMaps[ processed[1] ][depth] == nil then
        depthMaps[ processed[1] ][depth] = { 0, {} }
    end
    local depthLevelMap = depthMaps[ processed[1] ][depth]
    depthLevelMap[1] = depthLevelMap[1] + 1

    if name ~= nil then
        depthLevelMap[2][name] = depthLevelMap[1]
    end
end

local function addSubpoolEntry(subpool, entry)
    if subpool[1] == nil then
        table.insert(subpool.ids, entry)
    else
        for _, s in ipairs(subpool) do
            addSubpoolEntry(s, entry)
        end
    end
end

-- Also check if it exists on all superpools but the root
-- if not, add there too. A look-up table should work.
-- Actually no need for that. The users should expect others
-- drawing items from the higher subpools and account for that.
Pools.addToSubpool = function(str, id, mass)
    local processed = preprocessString(str)
    local subpool = getConfig(processed)
    local depth = #processed
    assert(depth ~= 1, 'One cannot add records to root config')
    addSubpoolEntry(subpool, { id = id, mass = mass or 1 })
end

-- TODO: record mask
Pools.instantiatePool = function(str)
    local processed = preprocessString(str)
    local index = processed[1]
    local rootPoolConfig = rootConfigs[index]

    local PoolType = usedType[index][1]
    local RecType = usedType[index][2]

    local items = {}
    for i, _ in ipairs(rootPoolConfig.items) do
        items[i] = RecType(i, 1, 1)
    end
    return PoolType(items, { subpools = rootPoolConfig.subpools }, randomness)
end


Pools.drawSubpool = function(str, pools, current)
    local split = preprocessString(str)

    local root = pools[ split[1] ]


    local subpool = toSubpool(root, split)

    if subpool.exhaust ~= nil and subpool:exhaust() then
        subpool = toSubpool(root, split)
    end

    return subpool
end


Pools.setPoolInListByName = function(name, pool, pools)
    local split = preprocessString(name)
    pools[ split[1] ] = pool
end

return Pools