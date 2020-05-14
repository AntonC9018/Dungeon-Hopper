
local Input = require 'game.input'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 8)
    world:addGameObjectType(Mods.Test.Entities.Chest)
    world:addGameObjectType(Mods.Test.Entities.Candace)
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
    local player = world:createPlayer(Mods.Test.Entities.Candace, Vec(4, 3))
    
    local chests = {}
    for i = 1, 10 do
        chests[i] = world:create(Mods.Test.Entities.Chest, Vec(i, 4))
    end


    local shield = Mods.Test.Items.shield.id
    local shell = Mods.Test.Items.shell.id
    
    TMAP = {}
    TMAP[shield] = 'shield'
    TMAP[shell] = 'shell'

    world:createDroppedItem(shield, Vec(2, 2))
    world:createDroppedItem(shell, Vec(2, 2))
    
    Input(world, function()
        local item = player.inventory:get(Mods.Test.Items.shell.slot)
        if item then
            local dropped = world.grid:getDroppedAt(Vec(2, 2))
            local did = dropped:getItemIds()
            print('The dropped item is a '..(TMAP[did[1]]))
        end
        
    end)
end