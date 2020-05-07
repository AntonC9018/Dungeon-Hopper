local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Inventory = require 'items.inventory'
local testItem = require 'modules.test.testitem'
local ItemTable = require 'items.itemtable'

ItemTable.registerItem(testItem)

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 20, 20)
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
    local inventory = Inventory(player)
    player.inventory = inventory
    local droppedItem = world:createDroppedItem(1, Vec(5, 4))
    local actions = {
        Vec(1, 0),
        Vec(1, 0),
        Vec(-1, 0),
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
            print(player:getStat(StatTypes.Attack).damage)

            -- if count == 2 then
            --     player:unequip(testItem)
            -- end
            print(player:getStat(StatTypes.Attack).damage)

        end,
        #actions
    )
end