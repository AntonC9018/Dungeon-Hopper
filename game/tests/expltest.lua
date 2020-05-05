local Explosion = require 'modules.test.explosion'
local StatTypes = require('logic.decorators.dynamicstats').StatTypes

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(Explosion)
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
    local expl = world:create( Explosion, Vec(2, 2) )
    expl:set(
        {
            direction = Vec(1, 0),
            attack = player:getStat(StatTypes.Attack),
            push = player:getStat(StatTypes.Push),
            explosionLevel = 1
        }
    )

    player:setStat(StatTypes.AttackRes, 'pierce', 0)
    player:setStat(StatTypes.PushRes, 0)

    local actions = {
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0),
        Vec(0, 0)
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
            print(player.hp:get())
            if not expl.dead then 
                print(expl.state)
            end
        end,
        #actions
    )
end