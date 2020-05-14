-- a super simplified version of pools which doesn't
-- upadte the quantities 

local InfPool = class("InfPool")

function InfPool:__construct(records, config, randomness)
    self.config = config
    self.randomness = randomness

    self:remapRecords(records)
    self:recalculateMass()
    self:instantiateSubpools(records)
end


function InfPool:remapRecords(records)
    if self.config.ids == nil then
        self.records = records
    else
        self.records = table.map(
            self.config.ids,
            function(recData)
                if type(recData) == 'table' then
                    return recData
                end
                return {
                    id = recData,
                    mass = records[recData].mass
                }
            end
        )
    end    
end

function InfPool:recalculateMass()
    self.totalMass = table.reduce(
        self.records, 
        function(a, rec)
            return a + rec.mass 
        end
    )
end


function InfPool:instantiateSubpools(records)
    self.subpools = {}

    if self.config.subpools then
        -- instantiate all subpools
        for i, subpoolConfig in ipairs(self.config.subpools) do
            self.subpools[i] = InfPool(
                records,
                subpoolConfig, 
                self.randomness
            )
        end
    end
end

function InfPool:getRandom()
    -- generate a random number between 1 and self.totalMass
    local mass = self:getRandomMass()

    -- find the record equal to the generated random mass
    -- For now, loop as normal.
    for _, rec in ipairs(self.records) do
        mass = mass - rec.mass
        if mass <= 0 then
            return rec.id
        end
    end
end


function InfPool:getRandomMass()
    -- for now, just use math.random()
    -- already passing along some `self.randomness`
    return math.random(self.totalMass)
end


return InfPool