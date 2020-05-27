local initWorld = require 'game.initworld'
local input = require 'game.input'
local Input = require 'game.input'
local Pools = require 'game.pools'
local Generator = require 'world.generation.generator'

return function()

    local generator = Generator(40, 40, { min_hallway_width = 2, max_hallway_width = 3, max_hallway_length = 1 })
    generator:start()
    generator:addNode(1, Vec(1, 0), 6, 6)
    generator:addNode(1, Vec(-1, 0), 6, 6)
    generator:addNode(1, Vec(0, -1), 6, 6)
    generator:addNode(1, Vec(0, 1), 6, 6)
    generator:addNode(2, Vec(0, 1), 6, 6)
    generator:generate()
    generator:secret(5, 5)
    generator:secret(4, 5)

    local world = initWorld({
        player = {
            character = Mods.Test.Entities.Candace,
            pos = Vec(4, 3)
        },
        generator = generator
    })

    Input(world, function()
    end)
end