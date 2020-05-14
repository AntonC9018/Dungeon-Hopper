
local Pool = require '@items.pool.pool'
local Record = require '@items.pool.record'


local function iterateSubpools(records, subpoolsConfig)
    local nodeSubpools = {}

    for i, s in ipairs(subpoolsConfig) do
        nodeSubpools[i] = {}

        local recs = {}
        for j, recIndex in ipairs(s.records) do
            recs[j] = records[recIndex]
        end
        nodeSubpools[i].records = recs

        if s.subpools ~= nil then
            nodeSubpools[i].subpools = 
                iterateSubpools(records, s.subpools)
        end
    end

    return nodeSubpools
end

-- used to turn the initial config into records
-- and these records are used to initialize the root
-- pool node with all the children pool nodes
-- 
-- TODO: each record should have a shared part (id and quantity)
-- and a private to each node part (the mass)
local function createPool(initialRecords, config)

    initialRecords = table.map(
        initialRecords,
        function(record)
            return Record(unpack(record))
        end
    )

    return Pool(initialRecords, { subpools = config })
end



return createPool