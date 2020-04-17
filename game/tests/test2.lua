
local function stats(enemy)
    printf("Health %i", enemy.hp:get())
    printf("Position:    %i, %i", enemy.pos.x, enemy.pos.y)
    printf("Orientation: %i, %i", enemy.orientation.x, enemy.orientation.y)
end

local function printWorld(world)
    
end

return function()
    local World = require('world.world')
    local world = World(4, 4)
    local player = world:createPlayerAt( Vec(2, 2) )
    local enemy = world:createTestEnemyAt( Vec(2, 3) )
    local success = world:setPlayerActions( Vec(0, 1), 1 )
    assert(success)
    local playerAction = player.nextAction
    -- print(ins(enemy, { depth = 1 }))

    
    world:render()
    print('\n')
    world:gameLoop()
    print('\n')

    world:setPlayerActions( Vec(0, 0), 1 )
    world:gameLoop()
    print('\n')

    world:setPlayerActions( Vec(0, 0), 1 )
    world:gameLoop()
    print('\n')

    world:setPlayerActions( Vec(0, 0), 1 )
    world:gameLoop()
    print('\n')
end