local Record = require '@items.pool.record'

local Pool = class("Pool")


-- 
--  initialRecords = { Record() },
--  sharedRecords =  { Record() }, -- these are deeply copied initialRecords
--  config = {
--      { ...indices... },
--      { ...subnodes(config)... }
--  },
--  randomness = ?,
--  parent

function Pool:__construct(
    initialRecords, 
    config,
    randomness,
    sharedRecords,
    parent
)

    -- if in the root node
    if parent == nil then
        self.initialRecords = initialRecords
        sharedRecords = table.deepClone(initialRecords)
    end

    self.config = config
    self.randomness = randomness
    self.parent = parent

    self:remapRecords(sharedRecords)
    self:recalculateMass()
    self:instantiateSubpools(sharedRecords)

end


function Pool:remapRecords(sharedRecords)

    if self:isRoot() then
        self.records = sharedRecords
    else
        self.records = table.map(
            self.config.ids,
            function(recData)
                if type(recData) == 'table' then
                    return { 
                        shared = sharedRecords[recData.id].shared, 
                        mass = recData.mass
                    }
                end
                return {
                    shared = sharedRecords[recData].shared,
                    mass = sharedRecords[recData].mass
                }
            end
        )
    end    
end


function Pool:recalculateMass()
    self.totalMass = table.reduce(
        self.records, 
        function(a, rec) 
            return a + rec.shared.q * rec.mass 
        end
    )
end


function Pool:instantiateSubpools(sharedRecords)
    self.subpools = {}

    if self.config.subpools then
        -- instantiate all subpools
        for i, subpoolConfig in ipairs(self.config.subpools) do
            self.subpools[i] = Pool(
                nil, 
                subpoolConfig, 
                self.randomness, 
                sharedRecords,
                self
            )
        end
    end
end

function Pool:recalculateMassChildren()
    for _, subpool in ipairs(self.subpools) do
        subpool:recalculateMass()
        subpool:recalculateMassChildren()
    end
end

-- The problem with storage is I either store items by id's
-- But have a hard time traversing the list
-- Or I store all items in one list one after the other
-- and have them also store their id.
--
-- The problem is that the first approach is a trouble for
-- retrieving a random value while the second is a trouble 
-- for updating the list to find the needed item and decrease
-- its quantity in the pool. This can be partially remedied by
-- the use of e.g. binary search since we can store the lists
-- sorted but hell we do lots of these second operations
-- 
-- May also use both while keeping the same objects in either
-- one, which works if you think about it.
--
-- I will go for the second option for now. 
-- Yeah, I want an id to record map too but we'll see.
--
-- For now we can assume all items are in this global pool

-- retrieve a random record and update all subpools
-- retrieves the random item from the global pool
function Pool:getRandom()
    -- generate a random number between 1 and self.totalMass
    local mass = self:getRandomMass()

    -- find the record equal to the generated random mass
    -- For now, loop as normal.
    local record
    for _, rec in ipairs(self.records) do
        mass = mass - rec.shared.q * rec.mass
        if mass <= 0 then
            record = rec
            break
        end
    end
    
    assert(record ~= nil)

    record.shared.q = record.shared.q - 1
    -- update total mass
    self:reduceMass(record.mass)

    self:updateOnRetrieval(record.shared.id, 1)

    return record.shared.id
end


function Pool:reduceMass(num)
    self.totalMass = self.totalMass - num
end


function Pool:getRandomMass()
    -- for now, just use math.random()
    -- already passing along some `self.randomness`
    return math.random(self.totalMass)
end


function Pool:update(id, reducedAmount)
    -- for now just loops through all records 
    -- and see if there is the given one
    -- TODO: use binary search
    for i, rec in ipairs(self.records) do
        if rec.shared.id == id then
            self:reduceMass(rec.mass * reducedAmount)
            return true
        end
    end
    return false
end


function Pool:updateOnRetrieval(id, reducedAmount, ignoredCaller) 
    -- if this has a parent pool, signal it to update its other subpools
    if self.parent ~= nil then
        self.parent:updateOnRetrieval(id, reducedAmount, self)
    end

    self:updateSubpools(id, reducedAmount, ignoredCaller)
end


function Pool:updateSubpools(id, reducedAmount, ignoredCaller)
    if 
        ignoredCaller == nil
        -- if the mass has been updated, update the children
        or self:update(id, reducedAmount)
    then
        -- update subpools
        for _, subpool in ipairs(self.subpools) do
            -- ignore the node that called this
            if ignoredCaller ~= subpool then
                subpool:updateSubpools(id, reducedAmount, self)
            end
        end
    end
end

function Pool:getRoot()
    local current = self
    while (current.parent ~= nil) do
        current = current.parent
    end
    return current
end

function Pool:isRoot()
    return self.parent == nil
end

-- now for the refill method
function Pool:exhaust(exhaustedPool)

    if exhaustedPool ~= nil then  
        -- 1. this should first be propagated up to the parent 
        --    node that should update the records' values
        --    depending on the exhausted pool's config records +
        --
        -- 2. the nodes below the exhausted node should be rein-
        --    stantiated from their configs. This can be done by
        --    calling exhaustedPool:__construct() again
        --
        -- 3. all the other nodes should be updated as per usual

        --  for now though, keep it going until the parent is reached
        if not self:isRoot() then
            return self.parent:exhaust(exhaustedPool)
        end

        -- after that, modify the records to include these values
        for _, rec in ipairs(exhaustedPool.records) do
            rec.shared.q = self.initialRecords[rec.shared.id].shared.q
        end

        self:recalculateMass()
        self:recalculateMassChildren()

        return true

    -- in the root node; we are the source
    elseif self:isRoot() then
        -- recreate the entire tree from the config, since
        -- the entire structure has been depleted
        if self.totalMass <= 0 then
            for id, rec in ipairs(self.records) do
                rec.q = self.initialRecords[id].shared.q
            end
            self:recalculateMass()
            self:recalculateMassChildren()
            return true
        end
    else
        -- we are the source; not in the root node
        -- propagate upwards after a check
        if self.totalMass <= 0 then
            return self.parent:exhaust(self)
        end
    end
    return false
end

return Pool