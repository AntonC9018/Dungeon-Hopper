
HOR_VER = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
DIAGONAL = { { 1, 1 }, { -1, -1 }, { -1, 1 }, { 1, -1 } }

Enemy = Entity:new{
    facing = { 1, 0 },
    dmg = 1,
    max_vision = 6,
    health = 3,
    sees = true
}

function Enemy:createSprite()
    -- error('An enemy class must override the createSprite() method')
end

-- abstract
function Enemy:getAction(w) end

-- abstract
function Enemy:move(action, w) end

function Enemy:getAction(player_action, w)
    
    if not self.cur_actions then
        self:computeAction(player_action, w)
    end

    return self.cur_actions

end

function Enemy:takeDamage(dir, dmg)
    self.moved = true
    self.hurt = true
    self.health = self.health - dmg

    if (self.health <= 0) then
        self.dead = true
        self.dmg = 0       
    end
end

function Enemy:reset()
    self.displaced = false
    self.hit = false
    self.hurt = false

    self.bounces = {}
    self.moved = false
    -- self.action_name = nil
    self.cur_actions = nil
    self.cur_audio = nil
    self.cur_a = nil
    self.cur_r = nil
    self.seq_count = (self.seq_count >= #self.sequence and 1) or (self.seq_count + 1)

    --[[
    
    self.
    
    ]]
end

function Enemy:die()
    transition.to(self.sprite, {
        alpha = 0,
        time = 600,
        transition = easing.linear,
        onComplete = function()
            display.remove(self.sprite)
        end
    })
end

function Enemy:face(p, dir)
    -- player is right to the right or to the left
    if math.abs(p.x - self.x) == 1 and math.abs(p.y - self.y) == 0 then
        -- self.facing = { p.x - self.x, 0 }
        return true
    -- player is right to the top or to the bottom
    elseif  math.abs(p.x - self.x) == 0 and math.abs(p.y - self.y) == 1 then
        -- self.facing = { p.y - self.y, 0 }
        return true
    end

    return false
end

function Enemy:getSeqStep()
    return self.sequence[self.seq_count]
end

function Enemy:updateSeq()
    self.seq_count = self.seq_count + 1
end