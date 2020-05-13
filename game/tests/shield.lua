local TestEnemy = require 'modules.test.entities.enemytest' 
local StatTypes = require('@decorators.dynamicstats').StatTypes
local Projectile = require 'modules.test.entities.projectile'
local BounceTrap = require 'modules.test.entities.bouncetrap'
local Input = require 'game.input'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 20, 20)
    world:addGameObjectType(Projectile)
    world:addGameObjectType(TestEnemy)
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
    local enemy = world:create(TestEnemy, Vec(8, 8))
    local droppedShiled = world:createDroppedItem( shield:getItemId(), Vec(5, 5) )


    Input(world, function()
        print(player.hp:get())
    end)

    -- proj:setStat(StatTypes.Push, 'power', 10)
    -- proj:setStat(StatTypes.Push, 'distance', 1)
end