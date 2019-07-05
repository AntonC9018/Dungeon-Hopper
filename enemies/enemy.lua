
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
    bounces = {}
}

function Enemy:createSprite()
    error('An enemy class must override the createSprite() method')
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
    self.health = self.health - dmg

    if (self.health <= 0) then
        self.dead = true
        self.dmg = 0       
    end

    print(self.health)
end
