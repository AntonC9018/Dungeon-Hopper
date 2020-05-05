local data = {}

data.StatConfigs = {

    -- put in here either the class of the effect
    -- or a table of properties to include with default values for each
    -- each effect has `modifier` property with same kind of modifiers as below
    { 'attack', require ('logic.action.effects.attack') }, -- damage 0, pierce 0
    { 'push',   require ('logic.action.effects.push')   }, -- power 0, distance 1
    { 'dig',    require ('logic.action.effects.dig')    }, -- damage 0, power 0
    { 'move',   require ('logic.action.effects.move')   }, -- distance 1, through false

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
            { 'pierce',    0         },
            { 'maxDamage', math.huge },
            { 'minDamage', 1         }
        }
    },

    { -- push res
        'resistance',
        {
            'push', 1 
        }
    },

    { -- dig res
        'resistance',
        {
            'dig', 1 
        }
    },

    { -- status res
        'resistance',
        {
            -- a huge list of statuses 
            -- (if default stats need be provided)
            { 'test', 0 }
        }
    },

    {
        'resistance',
        {
            'invincible', 0   
        }
    },

    {
        'resistance',
        {
            'explosion', 1
        }
    }
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
    StatusRes = 9,
    Invincible = 10,
    ExplRes = 11
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
    HowToReturn.STATS,
    HowToReturn.NUMBER,
    HowToReturn.NUMBER
}

return data