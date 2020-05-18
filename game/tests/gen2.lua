local initWorld = require 'game.initworld'
local input = require 'game.input'
local Input = require 'game.input'

local Ents = Mods.Test.Entities
local I = Mods.Test.Items

addSubpoolItem(ItemSubpools.Weapons,     I.spear.id)
addSubpoolItem(ItemSubpools.Weapons,     I.shield.id)
addSubpoolItem(ItemSubpools.Weapons,     I.shell.id)
addSubpoolItem(ItemSubpools.Trinkets,    I.testitem.id)
addSubpoolEntity(EntitySubpools.Enemies, Ents.TestEnemy.global_id)
-- addSubpoolEntity(EntitySubpools.Tiles,   Ents.Tile)
addSubpoolEntity(EntitySubpools.Walls,   Ents.Dirt.global_id)

return function()

    local world = initWorld({
        player = {
            character = Ents.Candace,
            pos = Vec(4, 3)
        },
        pools = {
            -- tile = EntitySubpools.Tiles,
            wall = EntitySubpools.Walls,
            enemy = EntitySubpools.Enemies,
            items = instantiateItemPool(),
            entities = instantiateEntityPool()
        },
        generator = true
    })

    Input(world, function()
    end)
end