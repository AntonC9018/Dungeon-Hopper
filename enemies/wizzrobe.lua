Wizzrobe = Enemy:new{
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
            -- redo this step if the function s3Loop() returns true
            loop = "s3Loop" 
        } 
    },
    seq_count = 1,
    health = 16,
    dmg = 1,
    size = { 0, 0 }
}

Wizzrobe:transformSequence()


function Wizzrobe:new(...)
    local o = Enemy.new(self, ...)
    return o
end

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
    self.sprite.x = self.x - self.size[1] / 2
    self.sprite.y = self.y + self.offset_y - self.size[2] / 2

    self.sprite:scale(self.scaleX, self.scaleY)
    self:anim(1000, 'idle')
end


function Wizzrobe:s3Loop()
    if 
        -- if was preparing to attack
        contains(self:getSeqStep().name, 'attack') and 
        -- but has bumped into an enemy
        Turn.was(self.history, 'bumped') and
        -- and hasn't attacked 
        not Turn.was(self.history, 'attack') and
        -- and hasn't bounced
        not Turn.was(self.history, 'bounced')
    then
        if self.close then
            self:anim(1000, "angry") 
        else
            self:anim(1000, "ready") 
        end        
        return true
    end
    return false
end