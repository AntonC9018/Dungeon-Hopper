return function()
    local World = require('world.world')
    local world = World(4, 4)
    local player = world:createPlayerAt( Vec(1, 1) )
    local enemy = world:createTestEnemyAt( Vec(1, 1) )
end