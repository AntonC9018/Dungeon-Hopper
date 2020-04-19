
local function stats(enemy)
    printf("Health %i", enemy.hp:get())
    printf("Position:    %i, %i", enemy.pos.x, enemy.pos.y)
    printf("Orientation: %i, %i", enemy.orientation.x, enemy.orientation.y)
end

local function printWorld(world)
    
end

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
    -- print('\n')

    -- world:setPlayerActions( Vec(0, 0), 1 )
    -- world:gameLoop()
    -- print('\n')

    -- world:setPlayerActions( Vec(0, 0), 1 )
    -- world:gameLoop()
    -- print('\n')
end