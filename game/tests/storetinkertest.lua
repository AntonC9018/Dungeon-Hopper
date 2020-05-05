local Spear = require 'modules.test.spear' 
local Weapon = require 'items.weapons.weapon'
local Player = require 'logic.base.player'
local TestEnemy = require 'modules.test.enemytest'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
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
    local player = world:createPlayerAt( Vec(2, 2) )


    local StoreTinker = require 'logic.tinkers.storetinker'
    local Move = require 'logic.tinkers.components.move'
    local RefStatTinker = require 'logic.tinkers.refstattinker'
    local utils = require 'logic.tinkers.utils'
    local StatTypes = require('logic.decorators.dynamicstats').StatTypes
    local Stats = require 'logic.stats.stats'

    local function generator(tinker)
        return 
        {
            { 
                'move', function(event)
                    local store = tinker:getStore(event.actor)
                    if store.i >= 3 then
                        tinker:untink(event.actor)
                        tinker:removeStore(event.actor)
                        print("Untinked")
                    else
                        store.i = store.i + 1
                        printf("Incrementing i. i = %i", store.i)
                    end
                end
            }
        }
    end

    local tinker = StoreTinker(generator)

    tinker:tink(player)
    tinker:setStore(player, { i = 0 })

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop() -- 0 -> 1

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop() -- 1 -> 2

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop() -- 2 -> 3

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop() -- removed

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop() -- not called
end