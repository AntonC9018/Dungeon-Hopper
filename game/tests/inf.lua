local initWorld = require 'game.initworld'
local input = require 'game.input'
local Ents = Mods.Test.Entities

local conf = {
    Ents.Crate.global_id, 
    Ents.BasicProjectile.global_id 
}
-- register a new subpool
registerEntitySubpool('Test', EntitySubpools.Global, conf)


return function()
    local world = initWorld({
        x = 10, y = 10,
        entityPool = instantiateEntityPool(),
        player = {
            character = Ents.Candace,
            pos = Vec(4, 3)
        },
        floor = Mods.Test.EntityBases.Tile
    })

    for i = 1, 10 do
        local id = world:getRandomEntityFromPool(1)
        world:create( Entities[id], Vec(i, 5) )
    end

    input(world)
end