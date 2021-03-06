local World = require 'world.world'
local Input = require 'game.input'
local render = require 'game.render'
local Generator = require 'world.generation.generator'

local defaultFloor = Mods.Test.Entities.Tile
local defaultWall  = Mods.Test.Entities.Dirt
local defaultEnemy = Mods.Test.Entities.TestEnemy

return function(config)
    local world = World(config.x, config.y)
    world:setRenderer(render.renderer)
    -- load all assets
    
    render.registerTypes()

    if config.pools then
        world:usePool('e', config.pools.entities)
        world:usePool('i', config.pools.items)
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
            generator:secret(5, 5)
            generator:secret(5, 5)
            generator:prune()
        else
            generator = config.generator
        end

        local entity, floor, wall = defaultEnemy, defaultFloor, defaultWall
        if config.pools then
            entity = config.pools.floor or entity
            floor = config.pools.floor or floor
            wall = config.pools.floor or wall
        end

        local center = world:materializeGenerator(
            generator, 
            floor, 
            wall,
            entity
        )
        world:createPlayer(config.player.character, center)
    else
        world:createFloors(config.floor or defaultFloor)
        
        if config.player then
            world:createPlayer(config.player.character, config.player.pos)
        end
        if config.enemies then
            for _, enemyConfig in ipairs(config.enemies) do
                world:create(enemyConfig.class, enemyConfig.pos)
            end
        end
    end
    

    Runtime:addEventListener( 
        "enterFrame",         
        function(event)
            render.renderer:update(event.time)
        end
    )

    return world
end