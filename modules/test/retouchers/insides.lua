local Ranks = require 'lib.chains.ranks'
local utils = require 'logic.retouchers.utils'
local OptionRealizers = require 'items.insides.realizers'
local OptionSetup = require 'items.insides.setup'

local insides = {}


local function setInsidesConstantGenerator(option)
    return function(event)
        local setup = OptionSetup[option.id]
                
        event.actor.insides = 
            setup and setup(event.actor, option) 
            or option        
    end
end

insides.setConstant = function(entityClass, option)
    utils.retouch(entityClass, 'init', setInsidesConstantGenerator(option))
end


local function setInsidesGenerator(config)
    -- calculate the total mass of all options
    local totalMass = 0
    for _, option in ipairs(config) do
        totalMass = totalMass + option[1]
    end
    
    return function(event)
        -- TODO: figure out a good way of generating random numbers
        local mass = math.random(0, totalMass)

        -- use the same procedure as with the pools
        for _, option in ipairs(config) do
            mass = mass - option[1]
            if mass <= 0 then
                local setup = OptionSetup[option[2].id]

                event.actor.insides = 
                    setup and setup(event.actor, option[2]) 
                    or option[2]

                return
            end
        end

        assert(false)
    end
end

insides.set = function(entityClass, config)
    utils.retouch(entityClass, 'init', setInsidesGenerator(config))
end


local function spawn(event)
    local option = event.actor.insides
    OptionRealizers[option.id](event.actor, option)
end


insides.spawnOnDeath = function(entityClass)
    utils.retouch(entityClass, 'die', spawn)
end


return insides