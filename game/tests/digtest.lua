return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
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
    local player = world:createPlayerAt( Vec(2, 2) )
    local dirt = world:createDirtAt( Vec(2, 3) )

    assert(world.grid:getWallAt(Vec(2, 3)) == dirt)
    assert(world.grid:hasBlockAt(Vec(2, 3)))

    timer.performWithDelay( 
        1000, 
        function()
            world:setPlayerActions( Vec(0, 1), 1 )
            world:gameLoop()
        end,
        7
    )
end