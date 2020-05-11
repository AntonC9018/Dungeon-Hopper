local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Chest = require 'modules.test.entities.chest'
local Candace = require 'modules.test.entities.candace'
local Input = require 'game.input'

local TestItem = require 'modules.test.items.testitem'
local ItemTable = require 'items.itemtable'
ItemTable.registerItem(TestItem)

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(Chest)
    world:addGameObjectType(Candace)
    world:addGameObjectType(TestItem)
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
    local player = world:createPlayer(Candace, Vec(4, 3))
    local chest = world:create(Chest, Vec(4, 4))
    local chest2 = world:create(Chest, Vec(4, 5))

    local createPool = require 'items.pool.create'

    local testRecords = { { 1, 1, 1 } }

    local testConfig = {
        {
            { 1 }, -- record id's to include
        }
    }

    local pool = createPool(testRecords, testConfig)

    local function handler(event)
        local item = pool.subpools[1]:getRandom()
        pool.subpools[1]:exhaust()
        print(ItemTable[item.id])
        world:createDroppedItem(item.id, event.actor.pos)
    end

    chest.chains.die:addHandler(handler)
    chest2.chains.die:addHandler(handler)

    Input(world, function()
        printf('Player damage: %i', player:getStat(StatTypes.Attack).damage)
    end)
end