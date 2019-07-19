
local Animated = {
    scaleX = 1 / 16,
    scaleY = 1 / 16
}

function Animated:new(o, options)
    o = o or {}
    setmetatable(o, self)
    self.__index = self    
    return o
end

function Animated:loadAssets(o)
    if o.sheet then
        self:loadSheet(o.sheet.path, o.sheet.options)
    end

    
    if o.audio then
        self.audio = {}
        for k, v in pairs(o.audio) do
            self.audio[k] = audio.loadSound(v)
        end
    end
end

function Animated:copyAssets(obj)
    self.sheet = obj.sheet
    self.audio = obj.audio
end


function Animated:playAudio(t)
    if t and self.audio[t] then
        audio.play(self.audio[t])
    end
end

function Animated:loadSheet(fname, options)
    self.sheet = graphics.newImageSheet(fname, options)
end

function Animated:orient(dir)
    self.sprite.xScale = dir * self.scaleX
end

function Animated:anim(ts, name)
    if not self.sprite.isPlaying or self.sprite.sequence ~= name then
        self.sprite.timeScale = 1000 / ts
        self.sprite:setSequence(name)
        self.sprite:play()
    end
end

function Animated:trans(o)
    transition.to(self.sprite, o)
end

return Animated