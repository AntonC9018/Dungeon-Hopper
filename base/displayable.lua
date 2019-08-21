-- local audio = require('audio')
local Displayable = class("Displayable")

Displayable.scale = 1 / UNIT
Displayable.offset = vec(0, -0.3)
Displayable.offset_y_jump = -0.2
Displayable.pos = vec(1, 1)
Displayable.size = vec(0, 0)


function Displayable:__construct(x, y, w)
    self.pos = vec(x, y)
    self.world = w
end

function Displayable:playAudio(t)
    local a = AM[class.name(self)].audio
    if t and a then
        audio.play(a[t])
    end
end


function Displayable:orient(dir)
    self.sprite.xScale = dir * self.scale
end

function Displayable:anim(ts, name)
    if not self.sprite.isPlaying or self.sprite.sequence ~= name then
        self.sprite.timeScale = 1000 / ts
        self.sprite:setSequence(name)
        self.sprite:play()
    end
end

function Displayable:createSprite(o, s)
    self.sprite = display.newSprite(self.world.group, AM[s or class.name(self)].sheet, o)
    self:setupSprite()
    return self.sprite
end

function Displayable:createImage(i, w, h, s)
    -- end
    self.sprite = display.newImageRect(self.world.group, AM[s or class.name(self)].sheet, i, w, h)
    self:setupSprite()
    return self.sprite
end

function Displayable:setupSprite()
    self.sprite.x = self.pos.x + self.offset.x + self.size.x / 2
    self.sprite.y = self.pos.y + self.offset.y + self.size.y / 2
    self.sprite.xScale = self.scale
    self.sprite.yScale = self.scale
end

Displayable.newImage = function(tab)
    local sprite = display.newImageRect(tab.world, AM[tab.class], tab.index, tab.width, tab.height)
    sprite.x = tab.owner.pos.x + tab.owner.offset.x + tab.owner.size.x / 2
    sprite.y = tab.owner.pos.y + tab.owner.offset.y + tab.owner.size.y / 2
    sprite.xScale = tab.owner.scale
    sprite.yScale = tab.owner.scale
    return sprite
end

function Displayable:toFront()
    self.sprite:toFront()
end

return Displayable