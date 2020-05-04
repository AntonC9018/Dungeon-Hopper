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


    local RefTinker = require 'logic.tinkers.reftinker'
    local Move = require 'logic.tinkers.move'
    local RefStatTinker = require 'logic.tinkers.refstattinker'
    local utils = require 'logic.tinkers.utils'
    local StatTypes = require('logic.decorators.dynamicstats').StatTypes
    local Stats = require 'logic.stats.stats'

    local i = 1;

    local function generator(tinker)
        return 
        {
            { 
                'move', function(event)
                    printf("Called %i times", i)
                    i = i + 1
                    tinker:untink(event.actor)
                end
            }
        }
    end

    local refTinker = RefTinker(generator)

    refTinker:tink(player)

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop()

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop()

    refTinker:tink(player)
    refTinker:untink(player)

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop()
end