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
        player = {
            character = Ents.Candace,
            pos = Vec(4, 3)
        },
        pools = {
            -- tile = EntitySubpools.Tiles,
            wall = 'e.~.~.wall',
            enemy = 'e.~.~.enemy',
            items = Pools.instantiateItemPool(),
            entities = Pools.instantiateEntityPool()
        },
        generator = true
    })

    Input(world, function()
    end)
end