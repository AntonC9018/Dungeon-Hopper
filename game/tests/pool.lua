local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Chest = require 'modules.test.entities.chest'
local Candace = require 'modules.test.entities.candace'
local Input = require 'game.input'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(Chest)
    world:addGameObjectType(Candace)
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

    local createPool = require 'items.pool.create'

    local testConfig = {
        records = { { 1, 1, 1 }, { 2, 2, 2 }, { 3, 1, 5 } },
        subpools = {
            {
                records = { 1, 2 },
                subpools = {
                    { 
                        records = { 1, 2 } 
                    },
                    {
                        records = { 2 }
                    }
                }
            },
            {
                records = { 1 }
            }
        }
    }

    local pool = createPool(testConfig)

    
    while (pool.totalMass ~= 0) do
        local rec = pool:getRandom()
        printf("\nTaken item by id %i", rec.id)
        printf("Root total mass: %i", pool.totalMass)
        printf("First child's total mass: %i", pool.subpools[1].totalMass)
        printf("First nested child's total mass: %i", pool.subpools[1].subpools[1].totalMass)
        printf("Second nested child's total mass: %i", pool.subpools[1].subpools[2].totalMass)
        printf("Second child's total mass: %i", pool.subpools[2].totalMass)
    end


    Input(world)
end