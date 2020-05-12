local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Chest = require 'modules.test.entities.chest'
local Candace = require 'modules.test.entities.candace'
local Input = require 'game.input'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 8)
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
    
    local chests = {}
    for i = 1, 10 do
        chests[i] = world:create(Chest, Vec(i, 4))
    end
    
    Input(world)
end