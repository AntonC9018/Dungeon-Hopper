local Enemy = require('base.enemy')
local Sequence = require('logic.sequence')

local Wizzrobe = class('Wizzrobe', Enemy)

Wizzrobe.seq = Sequence.transform(
    {
        -- do nothing for the first beat
        {
            name = "idle"
        },
        {
            -- do nothing too
            name = "idle",
            -- play the ready animation
            anim = "ready",
            -- if the player is close
            p_close = {
                -- play the angry animation
                anim = "angry",
                -- turn to player
                reorient = true
            }
        },
        {
            -- attack or move
            name = { "move", 'attack' },
            -- animations for "attack" and for "move" respectively
            -- if not specified, it would default to the name, i.e.
            -- { "move", "attack" }
            anim = { "jump", 'jump' },
            -- follow the basic movement pattern (orthogonal movement)
            mov = "basic",
            -- turn to player if close
            p_close = {
                reorient = true
            },
            -- redo this step if the function bumpLoop() returns true
            -- bumpLoop() is a function defined in the Enemy class
            loop = "bumpLoop"
        }
    }
)

Wizzrobe.hp_base = {
    t = 'red',
    am = 9
}

Wizzrobe.priority = 5000

Wizzrobe.size = vec(0, 0)

function Wizzrobe:__construct(...)
    Enemy.__construct(self, ...)
    self:createSprite({
        {
            name = "idle",
            frames = { 1, 3 },
            time = 1000,
            loopCount = 0
        },
        {
            name = "ready",
            start = 4,
            count = 1,
            time = math.huge
        },
        {
            name = "jump",
            frames = { 1, 3, 2, 3 },
            time = 1000,
            loopCount = 1
        },
        {
            name = "angry",
            start = 5,
            count = 1,
            time = math.huge
        }
    })
end


return Wizzrobe