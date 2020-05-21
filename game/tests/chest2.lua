local initWorld = require 'game.initworld'
local Input = require 'game.input'
local Pools = require 'game.pools'

Pools.addToSubpool('i.common.weapon', Mods.Test.Items.shell:getItemId())
Pools.addToSubpool('i.common.weapon', Mods.Test.Items.shield:getItemId())

return function()

    local itemPool = Pools.instantiatePool('i')

    local world = initWorld({
        x = 10, y = 10,
        player = {
            character = Mods.Test.Entities.Candace,
            pos = Vec(4, 3)
        },
        enemies = {
            {
                class = Mods.Test.Entities.Chest,
                pos = Vec(6, 3)
            },
            {
                class = Mods.Test.Entities.Chest,
                pos = Vec(6, 4)
            }
        },
        pools = {
            items = itemPool
        }
    })

    Input(world, function()
    end)
end
