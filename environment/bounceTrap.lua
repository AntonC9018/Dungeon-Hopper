
BounceTrap = Trap:new({
    push_ing = 5,
    push_amount = 1,
})


function BounceTrap:new(...)
    local o = Trap.new(self, ...)
    o.active = true
    o.dir = { math.random(-1, 1), math.random(-1, 1) }
    return o
end


-- for now assume it's a right pushing trap
function BounceTrap:activate(e, w)       
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


function BounceTrap:createSprite()
    self.sprite = display.newSprite(self.group, self.sheet, {
        {
            name = "main",
            frames = { 1, 2 },
            time = math.huge,
            loopCount = 0
        }
    })

    self.sprite.x = self.x
    self.sprite.y = self.y

    self.sprite:scale(self.scaleX, self.scaleY)
    self:rotate(self.dir)
    self:anim(1000, 'main')
end


function BounceTrap:reset()
    self.bounced = false
    Trap.reset(self)
end


function BounceTrap:rotate(dir)
    self.sprite.rotation = angleBetween({ 1, 0 }, dir) / math.pi * 180
end