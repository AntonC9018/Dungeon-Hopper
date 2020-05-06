local TestEnemy = require 'modules.test.enemytest' 
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Projectile = require 'modules.test.projectile'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 20, 20)
    world:addGameObjectType(Projectile) 
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
    local player = world:createPlayerAt( Vec(4, 4) )
    local proj = world:create(Projectile, Vec(6, 6))

    proj.orientation = Vec(-1, -1)

    proj:setStat(StatTypes.Push, 'power', 10)
    proj:setStat(StatTypes.Push, 'distance', 1)

    local actions = {
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0)
    }

    local count = 1

    timer.performWithDelay( 
        500, 
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