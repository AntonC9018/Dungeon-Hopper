local Enemy = require('enemies.enemy')
local Turn = require('turn')

local MiniWizzrobe = Enemy:new(
    {
        offset_y = -0.1,
        offset_y_jump = -0.2,
        sequence = {
            {
                name = "idle",

                p_close = {
                    reorient = true
                }
            },
            {
                name = { "move", "attack" },
                anim = { "jump", "jump" },
                mov = "diagonal",
                loop = "bumpLoop"
            }
        },
        health = 1,
        dmg = 2,
        priority = 4500
    }
)

MiniWizzrobe:transformSequence()
MiniWizzrobe:loadAssets(assets.Wizzrobe)

function MiniWizzrobe:new(...)
    local o = Enemy.new(self, ...)
    -- scale down 3 times
    o.scaleX = o.scaleX * 0.4
    o.scaleY = o.scaleY * 0.4
    o:createSprite()
    o:setupSprite()
    return o
end

function MiniWizzrobe:createSprite()
    self.sprite = display.newSprite(self.world.group, self.sheet, {
        {
            name = "idle",
            frames = { 1, 3 },
            time = 1000,
            loopCount = 0
        },
        {
            name = "jump",
            frames = { 1, 3, 2, 3 },
            time = 1000,
            loopCount = 1
        }
    })
end

return MiniWizzrobe