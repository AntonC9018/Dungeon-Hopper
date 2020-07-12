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
Pools.addToSubpool('e.1.*.enemy', Ents.Spider.class_id)
Pools.addToSubpool('e.1.*.enemy', Ents.TestEnemy.class_id)
Pools.addToSubpool('e.1.*.wall',  Ents.Dirt.class_id)

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
            items = Pools.instantiatePool('i'),
            entities = Pools.instantiatePool('e')
        },
        generator = true
    })

    Input(world, function()
    end)
end