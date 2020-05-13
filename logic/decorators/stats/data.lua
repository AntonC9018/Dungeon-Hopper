local data = {}

data.StatConfigs = {

    -- put in here either the class of the effect
    -- or a table of properties to include with default values for each
    -- each effect has `modifier` property with same kind of modifiers as below
    { 'attack', require ('@action.effects.attack') }, -- damage 0, pierce 0
    { 'push',   require ('@action.effects.push')   }, -- power 0, distance 1
    { 'dig',    require ('@action.effects.dig')    }, -- damage 0, power 0
    { 'move',   require ('@action.effects.move')   }, -- distance 1, through false

    {
        'status',
        {
        }
    },

    { -- attack res
        'attackRes',
        {
            { 'armor',     0         },
            { 'pierce',    0         },
            { 'maxDamage', math.huge },
            { 'minDamage', 1         },

            -- resistance against specific attack sources
            { 'normal', 1 }
        }
    },

    { -- push res
        'pushRes',
        {
            -- resistance against specific sources
            { 'normal', 1 } 
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
        }
    },

    {
        'resistance',
        {
            'invincible', 0   
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
    Invincible = 10
}

local HowToReturn = require '@decorators.stats.howtoreturn'

data.StatsHowToReturn = {
    HowToReturn.EFFECT,
    HowToReturn.EFFECT,
    HowToReturn.EFFECT,
    HowToReturn.EFFECT,
    HowToReturn.STATS,
    HowToReturn.STATS,
    HowToReturn.STATS,
    HowToReturn.NUMBER,
    HowToReturn.STATS,
    HowToReturn.NUMBER
}

return data