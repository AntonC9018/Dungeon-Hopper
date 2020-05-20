local initWorld = require 'game.initworld'
local Input = require 'game.input'

return function()

    local world = initWorld({
        x = 10, y = 10,
        player = {
            character = Mods.Test.Entities.Candace,
            pos = Vec(4, 3)
        },
        enemies = {
            {
                class = Mods.Test.Entities.TestEnemy,
                pos = Vec(6, 3)
            }
        }
    })

    Input(world, function()
    end)
end