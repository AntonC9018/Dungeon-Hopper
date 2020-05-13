-- There is a big problem with cross dependencies
--
-- Thing is, some of the handlers and tinkers and retouchers etc.
-- are interrelated. I want them to be able to access anything
-- there is in the game, including the entire mod, in the global
-- scope. Not like a handler name in the global scope or something,
-- something like:
--      `Decorators.Projectile`
--
-- should be available throughout the entire module if it is defined
-- anywhere within it. I don't want to explicitly require every 
-- decorator, I want it to be available by default on `Decorators`
-- This should at least be true for the very essential decorators.
-- Same for retouchers and tinkers.
--
-- It is clear that items and entities are at the top of the 
-- hierarchy: they are required last and they reference most things.
-- But this may not be the case! maybe some decorator wanted to 
-- reference a specific entity?
-- 
-- So this is what I figure will do. require e.g. handlers first, 
-- then e.g. effects, then interactors until we reach the very top.
-- I am going to prohibit the access to higher levels (at least for 
-- now). It is okey if they reference other things of the same level,
-- but they have to do it the normal way through usual requires.
--
-- There will be the following levels:
--      1. movs, algos, effects, actions
--      2. handlers, interactors
--      3. tinkers, retouchers
--      4. decorators
--      5. bases of entities and bases of items
--      6. entities and items
--
-- I also had the idea of allowing cross reference, by keeping track
-- of what objects have been required and what have not, but that would
-- still require everything to use requires, so no hope from there.
-- Since it is impossible to track references to variales in lua (I think)
-- meeeh too much rambling about.

-- require everything there is to the mod


local levels = {
    {
        -- 'Movs',
        -- 'Algos',
        'Effects',
        'Actions'
    },
    {
        'Handlers',
        'Interactors'
    },
    {
        'Tinkers',
        'Retouchers'
    },
    {
        'Decorators'
    },
    {
        { 'EntityBases', 'base' },
        { 'ItemBases',   'base' }
    },
    {
        'Entities',
        'Items'
    }
}

local lfs = require( "lfs" )

-- define a global variable that will optionally be used 
-- to define the name by which to store the required file's
-- output in the list
USE_NAME = nil

local function requireX(moduleName, folder)
    local result = {}

    local path = system.pathForFile("modules/"..moduleName.."/"..folder, thisFolder)

    for filename in lfs.dir(path) do

        local name = string.match(filename, '%D+%.lua')

        if 
            name ~= nil 
            and string.match(name, '__') == nil 
            and name ~= 'utils.lua'
        then
            name = string.lower(name)
            name = string.sub(name, 1, #name - 4)

            USE_NAME = nil
            local r = require('modules.'..moduleName..'.'..folder..'.'..name)

            if USE_NAME ~= nil then
                name = USE_NAME
            elseif class.is_class(r) then
                name = class.name(r)
            end

            result[name] = r
        end

    end

    return result
end


local moduleName = 'test'
local all = {}
for _, level in ipairs(levels) do
    for _, subname in ipairs(level) do
        if type(subname) == 'string' then
            all[subname] = requireX(moduleName, string.lower(subname))
        else
            all[subname[1]] = requireX(moduleName, string.lower(subname[2]))
        end
    end
end

print(ins(all, {depth = 3}))