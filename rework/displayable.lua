local Displayable = class("Displayable")

Displayable.scale = 1 / UNIT


function Displayable:loadAssets(code)
    local a = assets.code
    self:loadSheet(a.sheet.path, a.sheet.options)
    if not a.audio then return end
    self.audio = {}
    for k, v in pairs(self.audio) do
        self.audio[k] = audio.loadSound(v)
    end
end

function Displayable:playAudio(t)
    if t and self.audio[t] then
        audio.play(self.audio[t])
    end
end

function Displayable:loadSheet(fname, options)
    self.sheet = graphics.newImageSheet(fname, options)
end

function Displayable:orient(dir)
    self.sprite.scale = dir * self.scale
end

function Displayable:anim(ts, name)
    if not self.sprite.isPlaying or self.sprite.sequence ~= name then
        self.sprite.timeScale = 1000 / ts
        self.sprite:setSequence(name)
        self.sprite:play()
    end
end

function Displayable:createSprite(o)
    self.sprite = display.newSprite(self.world.group, self.sheet, o)
    self:setupSprite(self.pos.x, self.pos.y)
end

function Displayable:createImage(i, w, h)
    self.sprite = display.newImageRect(self.world.group, self.sheet, i, w, h)
    self:setupSprite(self.pos.x, self.pos.y)
end

function Displayable:setupSprite()
    self.sprite.x = self.pos.x
    self.sprite.y = self.pos.y
    self.sprite.scaleX = self.scale
    self.sprite.scaleY = self.scale
end

return Displayable