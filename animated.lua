constructor = {}

function constructor:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


Animated = {
    scaleX = 1 / 16,
    scaleY = 1 / 16
}

function Animated:new(o, options)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    if options then
        -- load the image sheet
        if options.sheet_path and not self.sheet then
            self:loadSheet(options.sheet_path, options.sheet_options)
        end

        -- load audio
        if options.audio and not self.audio then
            self.audio = {}
            for k, v in pairs(options.audio) do
                self.audio[k] = audio.loadSound(v)
            end
        end
    end

    return o
end

function Animated:play_audio(t)
    if t and self.audio[t] then
        audio.play(self.audio[t])
    end
end

function Animated:play_animation(g)
    if self.action_name then
        self.sprite:setSequence(self.action_name)
        self.sprite.timeScale = 1000 / g.getAnimLength() 
        self.sprite:play()
    end
end

function Animated:loadSheet(fname, options)
    self.sheet = graphics.newImageSheet(fname, options)
end

function Animated:orient(dir)
    self.sprite.xScale = dir * self.scaleX
end

function Animated:anim(ts, name)
    self.sprite.timeScale = 1000 / ts
    self.sprite:setSequence(name)
    self.sprite:play()
end

function Animated:trans(o)
    transition.to(self.sprite, o)
end
