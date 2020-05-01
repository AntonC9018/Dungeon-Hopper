local Cell = require 'world.cell'
local Water = require 'modules.test.water'
local Player = require 'logic.base.player'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(Water)
    world:registerTypes(assets)

    -- load all assets
    assets:loadAll()

    Runtime:addEventListener( 
        "enterFrame",         
        function(event)
            renderer:update(event.time)
        end
    )

    -- world:createFloors()

    local player = world:createPlayerAt( Vec(2, 2) )
    local waterTile = world:create( Water, Vec(2, 3) )

    assert(world.grid:getFloorAt( Vec(2, 3) ) == waterTile)

    local actions = {
        Vec(0, 1),
        Vec(0, 1),
        Vec(0, 1)
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