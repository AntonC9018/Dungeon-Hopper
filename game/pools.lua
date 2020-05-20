-- The format will be 
-- `i.rarity.category` for items and
-- `e.zone.floor` for entities
local Pool = require '@items.pool.pool'
local Record = require '@items.pool.record'
local InfPool = require '@items.pool.infinite.pool'
local InfRecord = require '@items.pool.infinite.record'


-- for now, the current stats are:
local current = {
    zone = 1,
    floor = 1,
    rarity = 1,
    category = 1
}

local itemDepthMap = {
    { 0, {} }, -- Rarity
    { 0, {} } -- category
}

local entityDepthMap = {
    { 0, {} }, -- Zone
    { 0, {} }, -- Floor
    { 0, {} }  -- layer ()
}


local itemPoolConfig = {
    subpools = {}
}
local entityPoolConfig = {
    subpools = {}
}

-- TODO: so, tilda is interpreted as taking the current pool state
-- TODO: (maybe) a dollar is interpreted as a random zone, floor etc.
-- for configs, though, the sting must be well-defined
local function preprocessString(str)
    local split = string.split(str, '.')
    local mapTilda, mapString

    if split[1] == 'i' then
        mapTilda = { current.rarity, current.category }
        mapString = itemDepthMap       
    elseif split[1] == 'e' then
        mapTilda = { current.zone, current.floor }
        mapString = entityDepthMap
    end

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

    local root

    if split[1] == 'i' then
        root = itemPoolConfig
    elseif split[1] == 'e' then
        root = entityPoolConfig
    else
        print('The pool `'..split[1]..'` is not supported. Custom pools aren\'t supported either yet')
    end

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

local function registerItemSubpool(name, config, parentPool, depth)
    register(parentPool, config)
    itemDepthMap[depth][1] = itemDepthMap[depth][1] + 1
    if name ~= nil then
        itemDepthMap[depth][2][name] = itemDepthMap[depth][1]
    end
end

local function registerEntitySubpool(name, config, parentPool, depth)
    register(parentPool, config)
    entityDepthMap[depth][1] = entityDepthMap[depth][1] + 1
    if name ~= nil then
        entityDepthMap[depth][2][name] = entityDepthMap[depth][1]
    end
end

local Pools = {}

Pools.registerSubpool = function(str, name, config)
    local processed  = preprocessString(str)
    local parentPool = getConfig(processed)
    local depth      = #processed
    if processed[1] == 'i' then
        registerItemSubpool(name, config, parentPool, depth)
    else
        registerEntitySubpool(name, config, parentPool, depth)
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
Pools.addToSubpool = function(str, id, mass)
    local processed = preprocessString(str)
    local subpool = getConfig(processed)
    local depth = #processed

    -- TODO: Also update all parents
    addSubpoolEntry(subpool, { id = id, mass = mass or 1 })
end

Pools.instantiateItemPool = function(randomness)
    -- for now, put one item with mass of one in each thing
    local items = {}
    for i, _ in ipairs(Items) do
        items[i] = Record(i, 1, 1)
    end
    -- TODO: sort configs by id in ascending order
    return Pool(items, itemPoolConfig, randomness)
end


-- TODO: make it possible to mask the global config
-- to customize the output
-- alternatively, make people copy and reset the world's config on 
-- e.g. player selection so that this method is never called
-- but then the objects will have to be made global
Pools.instantiateEntityPool = function(randomness)
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


Pools.drawSubpool = function(str, world)
    local split = preprocessString(str)

    local root

    if split[1] == 'i' then
        root = world.itemPool
        assert(root ~= nil)
    elseif split[1] == 'e' then
        root = world.entityPool
        assert(root ~= nil)
    else
        print('The pool `'..split[1]..'` is not supported. Custom pools aren\'t supported either yet')
    end

    return toSubpool(root, split)
end

return Pools