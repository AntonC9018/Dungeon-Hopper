local InfPool = require '@items.pool.infinite.pool'
local InfRecord = require '@items.pool.infinite.record'

local function createPool(initialRecords, config)

    initialRecords = table.map(
        initialRecords,
        function(record)
            return InfRecord(unpack(record))
        end
    )

    return InfPool(initialRecords, { subpools = config })
end

return createPool