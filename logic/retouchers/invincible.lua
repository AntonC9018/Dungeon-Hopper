local utils = require '@retouchers.utils'
local StatTypes = require('@decorators.dynamicstats').StatTypes
local Ranks = require 'lib.chains.ranks'

local invincibility = {}


local function preventDamage(event)
    event.propagate = event.actor:getStat(StatTypes.Invincible) > 0
end

invincibility.preventsDamage = function(entityClass)
    utils.retouch(entityClass, 'defence', { preventDamage, Ranks.HIGHEST })
end


local setFuncs = {}

local function setFunc(amount)

    if setFuncs[amount] == nil then

        setFuncs[amount] = function(event)
            if event.attack.damage > 0 then
                event.actor:setStat(StatTypes.Invincible, amount)
            end
        end

    end

    return setFuncs[amount]
end

invincibility.setAfterHit = function(entityClass, amount)
    utils.retouch(entityClass, 'beHit', setFunc(amount))
end


local function decreases(event)
    local i = event.actor:getStat(StatTypes.Invincible)
    if i > 0 then
        event.actor:setStat(StatTypes.Invincible, i)
    end
end

invincibility.decreases = function(entityClass)
    utils.retouch(entityClass, 'tick', decreases)
end


return invincibility