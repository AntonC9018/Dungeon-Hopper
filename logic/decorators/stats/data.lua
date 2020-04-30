local data = {}

data.StatConfigs = {

    -- put in here either the class of the effect
    -- or a table of properties to include with default values for each
    -- each effect has `modifier` property with same kind of modifiers as below
    { 'attack', require ('logic.action.effects.attack') },
    { 'push',   require ('logic.action.effects.push')   },
    { 'dig',    require ('logic.action.effects.dig')    },
    { 'move',   require ('logic.action.effects.move')   },    

    {
        'status',
        {
            { 'test', 0 }
        }
    },

    { -- attack res
        'resistance',
        {
            { 'armor',     0         },
            { 'pierce',    1         },
            { 'maxDamage', math.huge }
        }
    },

    { -- push res
        'resistance',
        {
            { 'push', 1 }
        }
    },

    { -- dig res
        'resistance',
        {
            { 'dig', 1 }
        }
    },

    { -- status res
        'resistance',
        {
            { 
                -- a huge list of statuses 
                -- (if default stats need be provided)
                { 'test', 0 }
            }
        }
    },

    -- TODO: move to separate files

    
}

-- Define the list of all types of stats
-- If some stat is not defined in this config but is accessed, it will be returned as 0
data.StatTypes = {
    Attack = 1,
    Push = 2,
    Dig = 3,
    Move = 4,
    Status = 5,
    AttackRes = 6,
    PushRes = 7,
    DigRes = 8,
    StatusRes = 9
}

local HowToReturn = require 'logic.decorators.stats.howtoreturn'

data.StatsHowToReturn = {
    HowToReturn.EFFECT,
    HowToReturn.EFFECT,
    HowToReturn.EFFECT,
    HowToReturn.EFFECT,
    HowToReturn.STATS,
    HowToReturn.STATS,
    HowToReturn.NUMBER,
    HowToReturn.NUMBER,
    HowToReturn.NUMBER
}

return data