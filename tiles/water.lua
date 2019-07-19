local TileBase = require('tiles.tileBase')

local Water = TileBase:new({
    stuck_ing = 50,
    stuck_amount = 1,
    stucker = false,
    type = 12
})

function Water:new(...)
    local o = TileBase.new(self, unpack(arg))
    o:createSprite()
    return o
end

function Water:activate(e, w)
    if self.stuck_ing > e.stuck_res and e ~= self.stucker then 
        e.stuck = self.stuck_amount
        e.just_stuck = true
        self.stucker = e
    end
end

function Water:reset(w)
    if self.stucker and self.stucker.stuck == 0 and self.world.entities_grid[self.x][self.y] ~= self.stucker then
        self.stucker = false
    end
end

return Water