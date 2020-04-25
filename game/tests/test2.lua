
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
    local enemy = world:createTestEnemyAt( Vec(2, 3) )

    
    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoopIfSet()

    timer.performWithDelay( 
        1000, 
        function()
            world:setPlayerActions( Vec(1, 0), 1 )
            world:gameLoop()
        end,
        7
    )
end