local Cell = require 'world.cell'
local Trap = require 'modules.test.trap'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(Trap)
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
    local trap = world:create( Trap, Vec(2, 3) )
    local trap2 = world:create( Trap, Vec(3, 3) )

    assert(world.grid.traps[1] == trap)
    assert(world.grid:getTrapAt( Vec(2, 3) ) == trap)
    assert(world.grid.reals[1] == player)
    assert(world.grid:getRealAt( Vec(2, 2) ) == player)
    assert(world.grid.grid[2][2].layers[Cell.Layers.real] == player)

    local actions = {
        Vec(0, 1),
        Vec(-1, 0)
    }

    local count = 1

    timer.performWithDelay( 
        1000, 
        function()
            world:setPlayerActions( actions[count], 1 )
            count = count + 1
            world:gameLoop()
        end,
        2
    )
end