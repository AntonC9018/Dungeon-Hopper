require 'modules.modloader'
local Input = require 'game.input'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 8)
    world:addGameObjectType(Mods.Test.Entities.Crate)
    world:addGameObjectType(Mods.Test.Entities.BasicProjectile)
    world:addGameObjectType(Mods.Test.Entities.Candace)
    world:registerTypes(assets)

    -- load all assets
    assets:loadAll()

    Runtime:addEventListener( 
        "enterFrame",         
        function(event)
            renderer:update(event.time)
        end
    )

    world:createFloors()

    local player = world:createPlayer(Mods.Test.Entities.Candace, Vec(4, 3))
    
    local createInfPool = require '@items.pool.infinite.create'

    local enemies = {}
    for i, _ in ipairs(Entities) do
        enemies[i] = { i, 1 }
    end

    local conf = {
        { 
            ids = { 
                Mods.Test.Entities.Crate.global_id, 
                Mods.Test.Entities.BasicProjectile.global_id 
            }
        }
    }

    local infPool = createInfPool(enemies, conf)
    for i = 1, 10 do
        local subpool = infPool.subpools[1]
        local id = subpool:getRandom()
        world:create( Entities[id], Vec(i, 5) )
    end

    Input(world, function()
    end)
end