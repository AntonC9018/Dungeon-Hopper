local Pool = class("Pool")


function Pool:__construct(config, randomness, parent)

    self.records = config.records    

    -- set up mass
    self.totalMass = 
        table.reduce(
            self.records, 
            function(a, rec) 
                return a + rec.q * rec.mass 
            end
        )

    self.subpools = {}    

    if config.subpools then
        -- instantiate all subpools
        for i, subpoolConfig in ipairs(config.subpools) do
            self.subpools[i] = Pool(subpoolConfig, randomness, self)
        end
    end

    self.randomness = randomness
    self.parent = parent

    -- store the config for further possible reinitialization
    -- self.config = {
    --     -- copy the records as they are constantly mutated
    --     records = table.deepClone(config.records),
    --     subpools = config.subpools
    -- }

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
        mass = mass - rec.q * rec.mass
        if mass <= 0 then
            record = rec
            break
        end
    end
    
    assert(record ~= nil)

    record.q = record.q - 1
    -- update total mass
    self:reduceMass(record.mass)

    self:updateOnRetrieval(record, 1)

    return record
end


function Pool:reduceMass(num)
    self.totalMass = self.totalMass - num
end


function Pool:getRandomMass()
    -- for now, just use math.random()
    -- already passing along some `self.randomness`
    return math.random(self.totalMass)
end


function Pool:update(record, reducedAmount)
    -- for now just loops through all records 
    -- and see if there is the given one
    -- TODO: use binary search
    for _, rec in ipairs(self.records) do
        if rec == record then
            self:reduceMass(record.mass * reducedAmount)
            return true
        end
    end
    return false
end


function Pool:updateOnRetrieval(record, reducedAmount, ignoredCaller)   
    -- if this has a parent pool, signal it to update its other subpools
    if self.parent ~= nil then
        self.parent:updateOnRetrieval(record, reducedAmount, self)
    end

    self:updateSubpools(record, reducedAmount, ignoredCaller)
end


function Pool:updateSubpools(record, reducedAmount, ignoredCaller)
    if 
        ignoredCaller == nil
        -- if the mass has been updated, update the children
        or self:update(record, reducedAmount)
    then
        -- update subpools
        for _, subpool in ipairs(self.subpools) do
            -- ignore the node that called this
            if ignoredCaller ~= subpool then
                subpool:updateSubpools(record, reducedAmount, self)
            end
        end
    end
end

-- now for the refill method
function Pool:exhaust(exhaustedPool)

    if exhaustedPool ~= nil then  
        -- 1. this should first be propagated up to the parent 
        --    node that should update the records' values
        --    depending on the exhausted pool's config records
        --
        -- 2. the nodes below the exhausted node should be rein-
        --    stantiated from their configs. This can be done by
        --    calling exhaustedPool:__construct() again
        --
        -- 3. all the other nodes should be updated as per usual

    -- in the root node, we are the source
    elseif self.parent == nil then
        -- recreate the entire tree from the config, since
        -- the entire structure has been depleted
        if self.totalMass <= 0 then
            self:__construct(self.config, self.randomness)
        end
    else

        -- we are the source, not in the parent node
        -- propagate upwards after a check
        if self.totalMass <= 0 then
            self.parent:exhaust(self)
        end
    end
end

return Pool