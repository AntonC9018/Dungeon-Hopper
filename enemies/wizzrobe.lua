
local Enemy = require('enemies.enemy')
local Turn = require('turn')
local MiniWizzrobe = require('enemies.miniWizzrobe')

local Wizzrobe = Enemy:new{
    offset_y = -0.3,
    offset_y_jump = -0.05,
    sequence = { 
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
            name = { "move", "attack" }, 
            -- animations for "attack" and for "move" respectively
            -- if not specified, it would default to the name, i.e.
            -- { "move", "attack" }
            anim = { "jump", "jump" }, 
            -- follow the basic movement pattern (orthogonal movement)
            mov = "basic", 
            -- turn to player if close
            p_close = {
                reorient = true
            },
            -- redo this step if the function s3Loop() returns true
            loop = "bumpLoop" 
        } 
    },
    health = 3,
    dmg = 1,
    priority = 5000
}

Wizzrobe:transformSequence()
Wizzrobe:loadAssets(assets.Wizzrobe)


function Wizzrobe:new(...)
    local o = Enemy.new(self, ...)
    o:createSprite()
    o:setupSprite()
    o:on('dead', function()
        local mw = o.world:spawn(o.x, o.y, MiniWizzrobe)
        mw.emitter:once('computeAction:start', function() mw.seq_step = 2 end)
        mw.moved = true
    end)
    return o
end

function Wizzrobe:createSprite()
    self.sprite = display.newSprite(self.world.group, self.sheet, {
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
            loopCount = 0,
            time = 0
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
            loopCount = 0,
            time = 0
        }
    })
end

return Wizzrobe