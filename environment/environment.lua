Environment = constructor:new{
    traps = {},
    bombs = {},
    -- items that lie on ground
    items = {}
}

function Environment:doTraps(w)
    for i = 1, #self.traps do

        local t = self.traps[i]

        if t.active and w.enemGrid[t.x][t.y] then
            t:activate(w.enemGrid[t.x][t.y], w)
        end

    end
end

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

function Environment:reset()
    for i = 1, #self.traps do
        self.traps[i].active = true
    end
end


Trap = Animated:new{
    active = true,
    push_ing = 5,
    push_amount = 1,
    v = { 1, 0 }
}

-- for now assume it's a right pushing trap
function Trap:activate(e, w)
    self.active = false
    if self.push_ing >= e.push_res then
        e:bounce(self.v, w)
        local x, y = e.bounces[#e.bounces]
        local t = w.environment:getTrapAt(x, y)
        if t and t.active then
            t:activate(e, w)
        end
    end
end

table.insert(Environment.traps, Trap:new{x = 2, y = 2})