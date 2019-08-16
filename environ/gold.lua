local Displayable = require('base.displayable')
local Gold = class('Gold', Displayable)

Gold.offset = vec(0, 0)

function Gold:__construct(am)
    self.am = am
end

Gold.__add[Gold] = function(self, rhs)
    local g = Gold(self.am + rhs.am)
    printf("Adding %d gold to %d gold", rhs.am, self.am)
    if self.sprite then
        g.sprite = self.sprite
        g.pos = self.pos
        g.world = self.world
        g:update()
    end
    return g
end

function Gold:drop(x, y, w)
    self.pos = vec(x, y)
    self.world = w
    local i = self:getImageIndex()
    self:createImage(i, UNIT, UNIT)
    self.sprite.aplha = 0
end

function Gold:getImageIndex()
    local steps = { 1, 2, 3, 4, 5, 15, 30, 45, 60, 90 }
    for i = #steps, 1, -1  do
        if self.am >= steps[i] then
            return i
        end
    end
end

function Gold:update()
    local i = self:getImageIndex()
    self.sprite:removeSelf()
    self:createImage(i, UNIT, UNIT)
end

function Gold:pickup()
    self.sprite:removeSelf()
end

function Gold:appear()
    self.sprite.alpha = 1
end

return Gold