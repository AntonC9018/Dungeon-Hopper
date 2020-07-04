local initWorld = require 'game.initworld'
local input = require 'game.input'
local Input = require 'game.input'
local Pools = require 'game.pools'

local Ents = Mods.Test.Entities
local I = Mods.Test.Items

Pools.addToSubpool('i.common.weapon',  I.spear.id)
Pools.addToSubpool('i.common.weapon',  I.shield.id)
Pools.addToSubpool('i.common.weapon',  I.shell.id)
Pools.addToSubpool('i.common.trinket', I.testitem.id)
Pools.addToSubpool('e.1.*.enemy', Ents.Spider.global_id)
Pools.addToSubpool('e.1.*.enemy', Ents.TestEnemy.global_id)
Pools.addToSubpool('e.1.*.wall',  Ents.Dirt.global_id)

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
    -- world.grid.players[1]:setStat(StatTypes.StatusRes, 'bind', 5)

    Input(world, function()
    end)
end