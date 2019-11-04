local Displayable = require('base.displayable')
local Gold = class('Gold', Displayable)

Gold.offset = Vec(0, 0)

function Gold:__construct(am)
    self.am = am
end

Gold.__add[Gold] = function(self, rhs)
    local g = Gold(self.am + rhs.am)
    printf("Adding %d gold to %d gold", rhs.am, self.am)
    if self.sprite then
        print('sprite found')
        g.sprites = self.sprites
        g.sprite = self.sprite
        g.pos = self.pos
        g.world = self.world
        g:update()
    end
    return g
end

function Gold:drop(x, y, w)
    self.pos = Vec(x, y)
    self.world = w

    -- initialize the sprites for each gold step
    self.sprites = {}
    for i = 1, 10 do
        self.sprites[i] = self:createImage(i, UNIT, UNIT)
        self.sprites[i].alpha = 0
    end

    -- find the needed exact image
    local i = self:getImageIndex()

    print(i)

    self.sprite = self.sprites[i]
end

function Gold:getImageIndex()
    local steps = { 1, 2, 3, 4, 5, 15, 30, 45, 60, 90 }
    for i = #steps, 1, -1 do
        if self.am >= steps[i] then
            return i
        end
    end
end

function Gold:update()
    local i = self:getImageIndex()
    self:swapImage(i)
end

function Gold:pickup()
    for i = 1, #self.sprites do
        self.sprites[i]:removeSelf()
    end
end

function Gold:swapImage(i)
    self.sprite.alpha = 0
    self.sprite = self.sprites[i]
    self.sprite.alpha = 1
end

function Gold:appear()
    self.sprite.alpha = 1
end

return Gold