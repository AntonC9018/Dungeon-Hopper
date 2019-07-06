
HOR_VER = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
DIAGONAL = { { 1, 1 }, { -1, -1 }, { -1, 1 }, { 1, -1 } }

Enemy = Entity:new{
    scaleX = 1 / 16,
    scaleY = 1 / 16,
    count = 1,
    facing = { 1, 0 },
    dmg = 1,
    dead = false,
    max_vision = 6,
    health = 3,
    bounces = {},
    sees = true
}

function Enemy:createSprite()
    -- error('An enemy class must override the createSprite() method')
end


function Enemy:getAction(g)
    local gx, gy = g.player.x > self.x, g.player.y > self.y
    local lx, ly = g.player.x < self.x, g.player.y < self.y

end


function Enemy:move(action, g)
end

function Enemy:getAction(player_action, g)
    
    if not self.cur_actions then
        self:computeAction(player_action, g)
    end

    return self.cur_actions

end

function Enemy:damage(dir, dmg)
    self.moved = true
    self.hit = true
    self.health = self.health - dmg

    if (self.health <= 0) then
        self.dead = true
        self.dmg = 0       
    end
end

function Enemy:reset()
    self.bounces = {}
    self.action_name = nil
    self.cur_actions = nil
    self.cur_audio = nil
    self.cur_a = nil
    self.cur_r = nil
    self.hit = false
    self.moved = false
    self.seq_count = (self.seq_count >= #self.sequence and 1) or (self.seq_count + 1)
end

function Enemy:die()
    transition.to(self.sprite, {
        alpha = 0,
        time = 600,
        onComplete = function()
            display.remove(self.sprite)
        end
    })
end

function Enemy:face(p, dir)
    -- player is right to the right or to the left
    if math.abs(p.x - self.x) == 1 and math.abs(p.y - self.y) == 0 then
        self.facing = { p.x - self.x, 0 }
        return true
    -- player is right to the top or to the bottom
    elseif  math.abs(p.x - self.x) == 1 and math.abs(p.y - self.y) == 0 then
        self.facing = { p.y - self.y, 0 }
        return true
    end

    return false
end