local initWorld = require 'game.initworld'
local input = require 'game.input'
local Input = require 'game.input'
local Pools = require 'game.pools'
local Generator = require 'world.generation.generator'

return function()

    local generator = Generator(60, 60, { min_hallway_width = 2, max_hallway_width = 3 })
    generator:start()
    generator:addNode(1, Vec(1, 0), 6, 6)
    generator:addNode(1, Vec(-1, 0), 6, 6)
    generator:addNode(1, Vec(0, -1), 6, 6)
    generator:addNode(1, Vec(0, 1), 6, 6)
    generator:generate()

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