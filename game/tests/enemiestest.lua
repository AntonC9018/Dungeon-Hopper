local Spear = require 'modules.test.spear' 
local Weapon = require 'items.weapons.weapon'
return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 20, 20)
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
    local player = world:createPlayerAt( Vec(5, 5) )

    for i = 4, 5 do
        for j = 3, 5 do
            if i ~= 5 or j ~= 5 then
                world:createTestEnemyAt( Vec(i, j) )
            end
        end
    end

    local actions = {
        Vec(0, -1),
        Vec(0, -1),
        Vec(0, -1),
        Vec(0, -1),
        Vec(0, -1)
    }

    local count = 1

    timer.performWithDelay( 
        1000, 
        function()
            local time = system.getTimer()
            world:setPlayerActions( actions[count], 1 )
            world:gameLoop()
            count = count + 1
            printf("Time passed: %i", system.getTimer() - time)
            print("-------------- Cycle ended. ---------------")
        end,
        #actions
    )
end