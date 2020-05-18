local World = require 'world.world'
local Input = require 'game.input'
local render = require 'game.render'
local Generator = require 'world.generation.generator'

local defaultFloor = Mods.Test.EntityBases.Tile
local defaultWall  = Mods.Test.Entities.Wall
local defaultEnemy = Mods.Test.Entities.TestEnemy

return function(config)
    local world = World(config.x, config.y)
    world:setRenderer(render.renderer)
    -- load all assets
    
    render.registerTypes()

    if config.pools then
        world:useEntityPool(config.pools.entities)
        world:useItemPool(config.pools.items)
    end
    
    render.assets:loadAll()

    if config.generator then
        local generator
        if config.generator == true then
            generator = Generator(60, 60)
            generator:start()
            generator:addNode(1)
            generator:addNode(1)
            generator:addNode(2)
            generator:addNode(2)
            generator:addNode(3)
            generator:generate()
        else
            generator = config.generator
        end

        print(generator)

        local center = world:materializeGenerator(
            generator, 
            config.pools.floor or defaultFloor, 
            config.pools.wall  or defaultWall, 
            config.pools.enemy or defaultEnemy
        )
        world:createPlayer(config.player.character, center)
    else
        if config.floor then
            world:createFloors(config.floor)
        end
        if config.player then
            world:createPlayer(config.player.character, config.player.pos)
        end
    end
    if config.itemPool then
        world:useItemPool(config.itemPool)
    end
    if config.entityPool then
        world:useEntityPool(config.entityPool)
    end
    

    Runtime:addEventListener( 
        "enterFrame",         
        function(event)
            render.renderer:update(event.time)
        end
    )

    return world
end