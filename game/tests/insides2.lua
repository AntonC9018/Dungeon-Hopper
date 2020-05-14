local initWorld = require 'game.initworld'
local input = require 'game.input'
local Input = require 'game.input'

local Ents = Mods.Test.Entities
local I = Mods.Test.Items

-- realized this right here ahs cross dependencies, which is really really bad.
-- The thing is, the chest references `ItemSubpools.Weaponry` to set up its id
-- which is done before this line is read, so it is nil at that point
-- A solution I propose:
--     1. require mods separately, after the general setup
--     2. define! empty subpools before requiring mods that
--        reference these subpools.
--     3. allow to add items to subpools after their definition
registerItemSubpool('Weaponry', 1, { I.spear.id, I.shield.id, I.shell.id })
registerItemSubpool('Stuffs', 1, { I.testitem.id })


return function()

    local world = initWorld({
        x = 10, y = 10,
        itemPool = instantiateItemPool(),
        player = {
            character = Ents.Candace,
            pos = Vec(4, 3)
        },
        floor = Mods.Test.EntityBases.Tile
    })
    
    local chests = {}
    for i = 1, 10 do
        chests[i] = world:create(Mods.Test.Entities.Chest, Vec(i, 4))
    end

    Input(world, function()
    end)
end