
local function stats(enemy)
    printf("Health %i", enemy.hp:get())
    printf("Position:    %i, %i", enemy.pos.x, enemy.pos.y)
    printf("Orientation: %i, %i", enemy.orientation.x, enemy.orientation.y)
end

return function()
    local World = require('world.world')
    local world = World(4, 4)
    local player = world:createPlayerAt( Vec(1, 1) )
    local enemy = world:createTestEnemyAt( Vec(1, 2) )
    local success = world:setPlayerActions( Vec(0, 1), 1 )
    assert(success)
    local playerAction = player.nextAction
    print(#world.grid.reals)
    print("Enemy stats before loop")
    stats(enemy)
    -- printf("")
    -- printf("")
    world:gameLoop()
    stats(enemy)

    print(#world.grid.reals)

end