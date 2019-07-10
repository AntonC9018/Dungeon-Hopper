Wizzrobe = Enemy:new{
    offset_y = -0.3,
    offset_y_jump = -0.2,
    sequence = { 
        { name = "idle", anim = "idle" }, 
        { name = "idle", anim = "ready", p_close = { anim = "angry" }, reorient = true },
        { name = { "move", "attack" }, anim = { "jump", "jump" }, mov = "adjacent-smart", loop = "bumped" } 
    },
    seq_count = 1,
    bounces = {},
    health = 4
}

Wizzrobe:transformSequence()

function Wizzrobe:createSprite()
    self.sprite = display.newSprite(self.group, self.sheet, {
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
    self.sprite.x = self.x
    self.sprite.y = self.y + self.offset_y

    self.sprite:scale(self.scaleX, self.scaleY)
    self:anim(1000, 'idle')
end

function Wizzrobe:takeHit(dir, player)
    -- TODO: call this something like 'weak'
    self.seq_count = 1

    Enemy.takeHit(self, dir, player)
end


function Wizzrobe:reset(w)
    if self.bumped then
        if self.close then
            self:anim(1000, "angry") 
        else
            self:anim(1000, "ready") 
        end
    end  
    Enemy.tickAll(self)
    Enemy.reset(self)
end