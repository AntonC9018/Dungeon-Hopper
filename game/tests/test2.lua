return function()
    local World = require('world.world')
    local world = World(4, 4)
    local player = world:createPlayerAt( Vec(1, 1) )
    assert(world.grid.players[1] == player)
    local enemy = world:createTestEnemyAt( Vec(1, 2) )
    local success = world:setPlayerActions(Vec(0, 1), 1)
    assert(success)
    local playerAction = player.nextAction
    world:gameLoop()
end