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
local Decorator = require 'logic.decorators.decorator'
local Stats = require 'logic.stats.stats'
local Data = require 'logic.decorators.stats.data'


local DynamicStats = class('DynamicStats', Decorator)


-- Map strings to indices
DynamicStats.StatTypes = Data.StatTypes
statTypesLength = #Data.StatConfigs
local StatConfigs = Data.StatConfigs
local HowToReturn = require 'logic.decorators.stats.howtoreturn'
local StatsHowToReturn = Data.StatsHowToReturn


DynamicStats.registerStat = function(name, config, howToReturn) 
    statTypesLength = statTypesLength + 1
    DynamicStats.StatTypes[name] = statTypesLength
    StatConfigs[statTypesLength] = config
    StatsHowToReturn[statTypesLength] = howToReturn
end


function DynamicStats:__construct(entity)

    -- convert the entities' basic stats into a dynamic stats object
    -- that is, an object for each of the entries in baseModifiers
    -- first, loop through all properties of baseModifiers and create
    -- Stats for each one specified.
    local statsList = {}
    self.statsChains = {}

    for k, v in pairs(entity.baseModifiers) do
        statsList[k] = Stats.fromTable(v)
        -- print('Added key '..k..' to stats') -- debug
    end

    for i, config in ipairs(StatConfigs) do
        local stat, attrs = config[1], config[2]        

        if statsList[stat] == nil then
            statsList[stat] = Stats()
        end

        -- create an empty chain here
        self.statsChains[i] = Chain()


        local function setStat(attr)
            local k, defaultValue = attr[1], attr[2]

            if not statsList[stat]:isSet(k) then
                statsList[stat]:set(k, defaultValue)
            end
        end

        if StatsHowToReturn[i] == HowToReturn.NUMBER then
            setStat(attrs)

        
        else
            -- got an effect wrapper class
            if StatsHowToReturn[i] == HowToReturn.EFFECT then
                -- take the modifier table for default values
                attrs = attrs.modifier
            end
            

            for _, p in ipairs(attrs) do 
                setStat(p)    
            end
        end
    end    

    self.statsList = statsList

end

-- get a specific stat
function DynamicStats:activate(actor, statIndex)

    if statIndex == nil then
        return 0
    end

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

    local event = Event(actor, nil)
    event.stats = concreteStats
    
    -- pass through chains
    self.statsChains[statIndex]:pass(event)

    -- wrap the stats if needed
    if howToReturn == HowToReturn.EFFECT then
        return entry[2](event.stats.stats)
    end

    return event.stats
end


function DynamicStats:setStat(statIndex, arg1, arg2)
    local stats = self.statsList[ StatConfigs[statIndex][1] ]
    
    -- this means we definitely return this value as a number
    -- and we expect it to be stored corresponding to a number in the config
    if type(arg1) == 'number' then
        stats:set( StatConfigs[statIndex][1][1], arg1 )

    -- arg1 is the name, arg2 is the amount
    elseif type(arg1) == 'string' then
        stats:set(arg1, arg2)

    else
        -- arg1 is actually a stats object
        stats:updateTo(arg1)
    end
end


function DynamicStats:addHandler(statIndex, handler)
    self.statsChains[statIndex]:addHandler(handler)
end


function DynamicStats:removeHandler(statIndex, handler)
    self.statsChains[statIndex]:removeHandler(handler)
end


return DynamicStats