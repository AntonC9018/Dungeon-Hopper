require 'modules.modloader'
local Input = require 'game.input'

local Projectile = Mods.Test.Entities.BasicProjectile
local BounceTrap = Mods.Test.Entities.BounceTrap
local Candace = Mods.Test.Entities.Candace

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 20, 20)
    world:addGameObjectType(Projectile)
    world:addGameObjectType(BounceTrap) 
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
    local player = world:createPlayer( Candace, Vec(4, 3) )
    local trap = world:create(BounceTrap, Vec(4, 4))
    trap.orientation = Vec(0, 1)
    local proj = world:create(Projectile, Vec(7, 5))
    proj.orientation = Vec(-1, 0)

    proj:setStat(StatTypes.Push, 'distance', 1)


    world.grid:watchOnto(Vec(4, 3), function() print('f') end, 1)


    Input(world, function()
    end)

end