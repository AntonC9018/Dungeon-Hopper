local initWorld = require 'game.initworld'
local input = require 'game.input'
local Input = require 'game.input'

local Ents = Mods.Test.Entities
local I = Mods.Test.Items

return function()    
    local generator = Generator(60, 60)
    generator:start()
    generator:addNode(1)
    generator:addNode(1)
    generator:addNode(2)
    generator:addNode(2)
    generator:addNode(3)
    generator:generate()

    local world = initWorld({
        player = {
            character = Ents.Candace
        },
        floor = Mods.Test.EntityBases.Tile,
        wall = Ents.Dirt,
        generator = generator
    })

    local player = world.grid.players[1]
    player:setStat(StatTypes.Dig, 'power', 5)

    Input(world, function()
    end)
end