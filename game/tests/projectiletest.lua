local TestEnemy = require 'modules.test.entities.enemytest' 
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Projectile = require 'modules.test.entities.projectile'
local BounceTrap = require 'modules.test.entities.bouncetrap'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 20, 20)
    world:addGameObjectType(Projectile)
    world:addGameObjectType(BounceTrap) 
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
    local player = world:createPlayerAt( Vec(4, 3) )
    local trap = world:create(BounceTrap, Vec(4, 4))
    trap.orientation = Vec(0, 1)
    local proj = world:create(Projectile, Vec(5, 5))
    proj.orientation = Vec(-1, 0)
    -- local proj = world:create(Projectile, Vec(9, 5))
    -- proj.orientation = Vec(-1, 0)

    -- proj:setStat(StatTypes.Push, 'power', 10)
    proj:setStat(StatTypes.Push, 'distance', 1)

    local actions = {
        Vec(0, 1),
        Vec(1, 0),
        Vec(1, 0),
        Vec(1, 0)
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