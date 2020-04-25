return function()
    local World = require('world.world')
    local world = World(5, 5)
    local player = world:createPlayerAt( Vec(2, 2) )
    local enemy = world:createTestEnemyAt( Vec(2, 3) )

    -- print(ins(world.grid:getCellAt(Vec(1, 1)).layers))

    local Cell = require "world.cell"
    local realList = world.grid:getCellAt( Vec(2, 2) ).layers[Cell.Layers.real]
    print(#realList)
    local real = world.grid:getRealAt( Vec(2, 2) )
    assert(player == real)
    local top = world:getOneFromTopAt( Vec(2, 2) )
    assert(top == player)
    top = world:getOneFromTopAt( Vec(2, 3) )
    assert(top == enemy)

end