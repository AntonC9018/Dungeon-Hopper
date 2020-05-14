local World = require 'world.world'
local Input = require 'game.input'
local render = require 'game.render'

return function(config)
    local world = World(config.x, config.y)
    world:setRenderer(render.renderer)
    -- load all assets
    
    render.registerTypes()
    
    if config.floor then
        local assetType = render.assets:getObjectType(config.floor)
        render.assets:registerGameObjectType(assetType)
        render.assets:loadAll()
        world:createFloors(config.floor)
    end
    if config.itemPool then
        world:useItemPool(config.itemPool)
    end
    if config.entityPool then
        world:useEntityPool(config.entityPool)
    end
    if config.player then
        world:createPlayer(config.player.character, config.player.pos)
    end

    Runtime:addEventListener( 
        "enterFrame",         
        function(event)
            render.renderer:update(event.time)
        end
    )

    return world
end