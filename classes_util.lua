constructor = {}

function constructor:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


Entity = {
    bounces = {}
}

function Entity:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    if o.options then
        -- load the image sheet
        if o.options.sheet_path and not self.sheet then
            self:loadSheet(o.options.sheet_path, o.options.sheet_options)
        end

        -- load audio
        if o.options.audio and not self.audio then
            self.audio = {}
            for k, v in pairs(o.options.audio) do
                self.audio[k] = audio.loadSound(v)
            end
        end
    end

    return o
end

function Entity:play_audio()
    if self.cur_audio and self.audio[self.cur_audio] then
        audio.play(self.audio[self.cur_audio])
    end
end

function Entity:play_animation(g)
    if self.action_name then
        self.sprite:setSequence(self.action_name)
        self.sprite.timeScale = 1000 / g.getAnimLength() 
        self.sprite:play()
    end
end

function Entity:loadSheet(fname, options)
    self.sheet = graphics.newImageSheet(fname, options)
end

function Entity:orient(dir)
    self.sprite.xScale = dir * self.scaleX
end