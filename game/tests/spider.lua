local initWorld = require 'game.initworld'
local input = require 'game.input'
local Input = require 'game.input'

local Ents = Mods.Test.Entities
local I = Mods.Test.Items

addSubpoolItem(ItemSubpools.Weapons,     I.spear.id)
addSubpoolItem(ItemSubpools.Weapons,     I.shield.id)
addSubpoolItem(ItemSubpools.Weapons,     I.shell.id)
addSubpoolItem(ItemSubpools.Trinkets,    I.testitem.id)
addSubpoolEntity(EntitySubpools.Enemies, Ents.Spider.global_id)
-- addSubpoolEntity(EntitySubpools.Tiles,   Ents.Tile)
addSubpoolEntity(EntitySubpools.Walls,   Ents.Dirt.global_id)

return function()

    local world = initWorld({
        x = 10, y = 10,
        player = {
            character = Ents.Candace,
            pos = Vec(4, 3)
        },
        enemies = {
            {
                class = Ents.Spider,
                pos = Vec(4, 4)
            },
            {
                class = Ents.TestEnemy,
                pos = Vec(6, 3)
            }
        }
    })

    world.grid.players[1]:setStat(StatTypes.Push, 'power', 2)

    Input(world, function()
    end)
end