-- The idea of this decorator is to provide a simpler interface 
-- for getting an entities' stats (resistances, attacks etc.)
-- kind of like this: `entity:getStat(StatTypes.Attack, ...)`
-- which would return an already modified by all items attack
-- effect. 
--
-- This decorator will also provide easier ways to modify
-- specific stats, by calling the method that modifies the stats
-- directly.
--
-- Also, it will provide a chain for each of the stats, in case
-- the modification logic is not as simple as just adding or
-- removing attack damage. This chain will be traversed before 
-- returning the stat (or effect).
--
local Decorator = require '@decorators.decorator'
local Stats = require '@stats.stats'
local Data = require '@decorators.stats.data'
local Chain = require 'lib.chains.chain'

local DynamicStats = class('DynamicStats', Decorator)


-- Map strings to indices
DynamicStats.StatTypes = Data.StatTypes
local statTypesLength = #Data.StatConfigs
local StatConfigs = Data.StatConfigs
local HowToReturn = require '@decorators.stats.howtoreturn'
local StatsHowToReturn = Data.StatsHowToReturn


DynamicStats.registerStat = function(name, config, howToReturn) 
    statTypesLength = statTypesLength + 1
    DynamicStats.StatTypes[name] = statTypesLength
    StatConfigs[statTypesLength] = config
    StatsHowToReturn[statTypesLength] = howToReturn
end

-- this function adds the specified attribute to the
-- selected stat modifier 
DynamicStats.addAttribute = function(statIndex, attribute)
    -- this applies to STATS only
    assert(StatsHowToReturn[statIndex] == HowToReturn.STATS)
    -- add the attribute to the attribute list
    table.insert(StatConfigs[statIndex][2], attribute)
end


function DynamicStats:__construct(entity)

    self.actor = entity

    -- convert the entities' basic stats into a dynamic stats object
    -- that is, an object for each of the entries in baseModifiers
    -- first, loop through all properties of baseModifiers and create
    -- Stats for each one specified.
    self.statsList = {}

    -- contains updateable chain for each of the stats
    self.statsChains = {}

end

-- figure if a stat has been lazy loaded already
function DynamicStats:assertLoaded(statIndex)
    if self.statsChains[statIndex] == nil then
        self:lazyLoad(statIndex)
    end
end


function DynamicStats:lazyLoad(statIndex)

    local entry = StatConfigs[statIndex]
    local stat = entry[1]
    local howToReturn = StatsHowToReturn[statIndex]
    
    -- if the stat's table doesn't exist, create one
    if self.statsList[stat] == nil then

        -- if base modifiers contains the stat, use it
        if self.actor.baseModifiers[stat] ~= nil then
            self.statsList[stat] = Stats.fromTable(self.actor.baseModifiers[stat])
        
        else
            self.statsList[stat] = Stats() 
        end
    end

    local attributes = entry[2]

    -- load default values if any value is not set
    local function setStat(attr)
        local key, defaultValue = attr[1], attr[2]

        if not self.statsList[stat]:isSet(key) then
            self.statsList[stat]:set(key, defaultValue)
        end
    end

    if howToReturn == HowToReturn.NUMBER then
        setStat( attributes )

    
    else
        -- got an effect wrapper class
        if howToReturn == HowToReturn.EFFECT then
            -- take the modifier table for default values
            attributes = attributes.modifier
        end        

        for _, a in ipairs(attributes) do 
            setStat(a)    
        end
    end

    -- create a chain
    self.statsChains[statIndex] = Chain()

end

-- get a specific stat
function DynamicStats:getStat(statIndex)
    
    if statIndex == nil then
        return 0
    end

    self:assertLoaded(statIndex)  

    local entry = StatConfigs[statIndex]
    local stat = entry[1]
    local stats = self.statsList[stat]
    local howToReturn = StatsHowToReturn[statIndex]

    local concreteStats

    if howToReturn == HowToReturn.NUMBER then
        -- unwrapping entry: { statName, { 'key', defaultValue } }
        concreteStats = stats:get(entry[2][1])
    else
        concreteStats = Stats()
        for _, p in 
            ipairs(
                howToReturn == HowToReturn.STATS 
                and entry[2]
                or entry[2].modifier
            ) 
        do             
            local key = p[1]
            concreteStats:set(key, stats:get(key))
        end
    end


    local event = Event(self.actor, nil)
    event.stats = concreteStats
    
    -- pass through chains
    self.statsChains[statIndex]:pass(event)

    -- wrap the stats if needed
    if howToReturn == HowToReturn.EFFECT then
        return entry[2](event.stats.stats)
    end

    return event.stats
end


function DynamicStats:getStatRaw(statIndex)
    self:assertLoaded(statIndex)
    return self.statsList[ StatConfigs[statIndex][1] ]
end


function DynamicStats:setStat(statIndex, arg1, arg2)
    
    self:assertLoaded(statIndex)

    local stats = self.statsList[ StatConfigs[statIndex][1] ]
    
    -- this means we definitely return this value as a number
    -- and we expect it to be stored corresponding to a number in the config
    if type(arg1) == 'number' then
        stats:set( StatConfigs[statIndex][2][1], arg1 )

    -- arg1 is the name, arg2 is the amount
    elseif type(arg1) == 'string' then
        stats:set(arg1, arg2)

    else
        -- arg1 is actually a stats object
        stats:updateTo(arg1)
    end
end


function DynamicStats:addStat(statIndex, arg1, arg2)
    
    self:assertLoaded(statIndex)

    local stats = self.statsList[ StatConfigs[statIndex][1] ]
    
    -- this means we definitely return this value as a number
    -- and we expect it to be stored corresponding to a number in the config
    if type(arg1) == 'number' then
        stats:add( StatConfigs[statIndex][2][1], arg1 )

    -- arg1 is the name, arg2 is the amount
    elseif type(arg1) == 'string' then
        stats:add(arg1, arg2)

    else
        -- arg1 is actually a stats object
        stats:addStats(arg1)
    end

end


function DynamicStats:addHandler(statIndex, handler)
    
    self:assertLoaded(statIndex)

    self.statsChains[statIndex]:addHandler(handler)
end


function DynamicStats:removeHandler(statIndex, handler)

    self:assertLoaded(statIndex)

    self.statsChains[statIndex]:removeHandler(handler)
end


return DynamicStats