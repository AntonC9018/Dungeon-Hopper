local Cell = require 'world.cell'
local Trap = require 'modules.test.trap'
local TestEnemy = require 'modules.test.enemytest'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(Trap)
    world:addGameObjectType(TestEnemy)
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
    local player = world:createPlayerAt( Vec(2, 3) )
    local trap = world:create( Trap, Vec(2, 5) )
    trap.orientation = Vec(0, -1)
    local enemy = world:create( TestEnemy, Vec(2, 6) )

    local actions = {
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0)
    }

    local count = 1

    timer.performWithDelay( 
        1000, 
        function()
            world:setPlayerActions( actions[count], 1 )
            world:gameLoop()
            count = count + 1
            print(player.hp:get())
        end,
        2
    )
end