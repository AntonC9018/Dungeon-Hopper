local Cell = require 'world.cell'

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

    -- Traps set up like so
    --
    -- → ↓
    -- ↑ ←
    --
    local trap = world:createTrapAt( Vec(2, 3) )
    trap.orientation = Vec(1, 0)
    local trap2 = world:createTrapAt( Vec(3, 3) )
    trap2.orientation = Vec(0, 1)
    local trap3 = world:createTrapAt( Vec(3, 4) )
    trap3.orientation = Vec(-1, 0)
    local trap4 = world:createTrapAt( Vec(2, 4) )
    trap4.orientation = Vec(0, -1)


    local actions = {
        Vec(0, 1),
        Vec(-1, 0)
    }

    local count = 1

    timer.performWithDelay( 
        1000, 
        function()
            world:setPlayerActions( actions[count], 1 )
            world:gameLoop()
            count = count + 1
        end,
        #actions
    )
end