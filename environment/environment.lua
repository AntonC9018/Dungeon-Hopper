Environment = constructor:new{
    traps = {},
    bombs = {},
    -- items that lie on ground
    items = {},
    expls = {}
}

function Environment:doTraps(w)
    for i = 1, #self.traps do

        local t = self.traps[i]

        if t.active then
            if w.entities_grid[t.x][t.y] then
                t:activate(w.entities_grid[t.x][t.y], w)
            else
                t.bounced = false
            end
        end
    end
end

-- function Environment:doExpls(w)
--     for i = 1, #self.expls do


--     end
-- end

-- TODO: improve this, this is no good
function Environment:getTrapAt(x, y)
    for i = 1, #self.traps do
        if self.traps[i].x == x and self.traps[i].y == y then
            return self.traps[i]
        end
    end
end

-- TODO: improve this, this is no good
function Environment:getBombAt(x, y)
    for i = 1, #self.bomb do
        if self.bomb[i].x == x and self.bomb[i].y == y then
            return self.bomb[i]
        end
    end
end

-- TODO: improve this, this is no good
function Environment:getItemAt(x, y)
    for i = 1, #self.items do
        if self.items[i].x == x and self.items[i].y == y then
            return self.items[i]
        end
    end
end

function Environment:act(w)
    self:doTraps(w)
end

function Environment:updateSprites(w)
    for i = #self.expls, 1, -1 do
        local e = self.expls[i]
        if e.ended then 
            table.remove(self.expls, i)
            e.sprite:removeSelf()
        else
            e:tick()
        end
    end
end

function Environment:reset(w)
    for i = 1, #self.traps do
        local t = self.traps[i]
        if not w.entities_grid[t.x][t.y] then
            t:reset()
        end
    end       
end

function Environment:toFront(str)
    for i = 1, #self[str] do
        self[str][i].sprite:toFront()
    end
end

-- explode the tiles within radius of r around the specified coordinate
function Environment:explode(x, y, r, w)
    -- the idea is to create an explosion for each of the tiles 
    -- of a square, centered at (x, y), that has width of r
    for i = -r, r do
        for j = -r, r do
            Environment:explodeAt(
                x + i, y + j, 
                normComps({ i, j }), 
                w
            )
        end
    end
    self.expls[#self.expls]:playAudio('boom')

end

function Environment:explodeAt(x, y, dir, w)
    local e = Explosion:new({ x = x, y = y, dir = dir })
    e:explode(w)
    e:createSprite()
    table.insert(self.expls, e)
end

