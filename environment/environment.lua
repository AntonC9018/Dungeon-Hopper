Environment = constructor:new{
    traps = {},
    bombs = {},
    -- items that lie on ground
    items = {}
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
        self.traps[i]:anim(1000, 'active')
    end
end

function Environment:toFront()
    for i = 1, #self.traps do
        self.traps[i].sprite:toFront()
    end
end


Trap = Animated:new(
    {
        active = true,
        push_ing = 5,
        push_amount = 1,
        dir = { 1, 0 }
    }
)


function Trap:createSprite()
    self.sprite = display.newSprite(self.group, self.sheet, {
        {
            name = "active",
            frames = { 1 },
            time = 0,
            loopCount = 0

        },
        {
            name = "inactive",
            frames = { 2 },
            time = 0,
            loopCount = 0
        }
    })

    self.sprite.x = self.x
    self.sprite.y = self.y

    self.sprite:scale(self.scaleX, self.scaleY)
    self:anim(1000, 'active')
end


-- for now assume it's a right pushing trap
function Trap:activate(e, w)   

    
    if self.push_ing > e.push_res and e ~= self.bounced then

        self.active = false
        
        e:bounce(self, w)
        
        if self.x == e.x and self.y == e.y then
            self.bounced = e
        else
            self.bounced = false
        end

        local t = w.environment:getTrapAt(x, y)
        if t and t.active then
            t:activate(e, w)
        end
    end
end
