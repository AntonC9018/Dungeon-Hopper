-- The mod main files are just config files.
-- We've got to require them and then just add their content into
-- global lists.


-- One complication is that there are thing that have to be defined before
-- the other content of the mod and it expects that content to be there
-- I may limit or forbid that, don't know what to do about it yet
--
-- E.g. the chest gets the item pool id from the global pool config
-- at the time of class definition, so it expects it to be available
-- globally at that time. Potential workarounds:
--      1. use strings instead of ids for selecting a pool (ok)
--      2. use a function of getting a pool (ok, but a bit worse)
--      3. store the pools themselves as strings (meh)
--
-- The solution I came up with is that we should store the pools differently.
-- For entities, split the global (root) pool (basically a list of all entities)
-- into zone pools, which would be in turn split into floors (or some more
-- generic name. In case we go for an open world game, the `zone` still makes
-- sense, while the `floor` not so much. Also, difficulty settings will have
-- to be addressed at some point, which may in theory affect the pools too).
-- For items, split the global pool by quality or rarity (e.g. common, uncommon etc.)
--
-- The pools will be addressed by using string with number. Something like
-- `e.1.1` would mean entities of first floor of first zone, 
-- while `e.~.~` would mean the current floor of the current zone. 
-- For items:
-- `i.~.weapon` means the weapon subpool of the current rarity level
-- e.g. `i.$.weapon` would mean to randomize the rarity
-- `i.rare.weapon` would mean a rare weapon
-- This is all just an outline, but it already starts looking a lot more organized 
local Effect = require '@action.effects.effect'

Mods = {}


local function loadMod(modName, content)
    local mod = {}
    
    if content.entities then
        for name, entityClass in pairs(content.entities) do
            registerEntity(entityClass)
        end
        mod.Entities = content.entities
    end

    if content.items then
        for name, item in pairs(content.items) do
            registerItem(item)
        end    
        mod.Items = content.items
    end

    -- register attack sources used in the module
    if content.attackSources then
        for _, src in ipairs(content.attackSources) do
            registerAttackSource(src)
        end
    end

    if content.stats then
        -- the how to return is thereof deduced here
        for name, conf in pairs(content.stats) do
            local howToReturn
            if class.is(conf[2], Effect) then
                howToReturn = HowToReturn.EFFECT
            elseif 
                conf[2][1] == nil 
                or type(conf[2][1]) == 'table' 
            then
                howToReturn = HowToReturn.STATS
            else
                howToReturn = HowToReturn.NUMBER
            end
            registerStat(name, conf, howToReturn)
        end
    end

    if content.status then
        for name, status in pairs(content.status) do
            registerStatus(name, status)
        end
    end

    -- TODO: do the rest
    return mod
end


MODULE_NAME = 'test'
local content = require 'modules.test.main'
local Test = loadMod('Test', content)
Mods.Test = Test

