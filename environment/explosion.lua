local Animated = require('animated')

local Explosion = Animated:new{}

Explosion:loadAssets(assets.Explosion)

function Explosion:new(...)
    local o = Animated.new(self, ...)
    o.dmg = 4
    o.specials = {
        push_ing = 50,
        push_amount = 1,
        explode_ing = 50,
        pierce_ing = 50
    }
    o.framecount = 1
    o.ended = false
    o:createSprite()
    return o
end

function Explosion:createSprite()
    self.sprite = display.newSprite(self.world.group, self.sheet, {
        {
            name = "main",
            start = 1,
            count = 3,
            time = math.huge
        }
    })

    self.sprite.x = self.x
    self.sprite.y = self.y

    self.sprite:scale(self.scaleX, self.scaleY)
    self:anim(1000, 'main')
end


function Explosion:explode(w)
    local t = w.entities_grid[self.x][self.y]

    if t then
        if self.specials.explode_ing > t.explode_res then
            t:takeHit(self, w)
        end
    end
end

function Explosion:tick(w)
    self.sprite:setFrame(self.framecount)
    self.framecount = self.framecount + 1
    if self.framecount > self.sprite.numFrames then
        self.ended = true
    end
end

return Explosion