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
            e:show()
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

function Environment:toFront()
    for i = 1, #self.traps do
        self.traps[i].sprite:toFront()
    end
    for i = 1, #self.expls do
        self.expls[i].sprite:toFront()
    end
end

function Environment:explode(r)
end

function Environment:explodeAt(x, y, w)
    local e = Explosion:new({ x = x, y = y })
    e:createSprite()
    e:explode(w)
    table.insert(self.expls, e)
end

