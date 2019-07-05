constructor = {}

function constructor:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


Entity = {}

function Entity:new(o, options)
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
                self.audio[k] = audio.loadAudio(v)
            end
        end
    end

    self:createSprite()

    return o
end

function Entity:play_audio()
    if self.cur_audio and self.audio[self.cur_audio] then
        audio.play(self.audio[self.cur_audio])
    end
end

function Entity:play_animation(g)
    if self.action_name then
        self.sprite:setSequence(action_name)
        self.sprite.timeScale = 1000 / g.getAnimLength() 
        self.sprite:play()
    end
end

function Entity:createSprite()
end

function Entity:loadSheet(fname, options)
    self.sheet = graphics.newImageSheet(fname, options)
end

function Entity:orient(dir)
    self.sprite.xScale = dir * self.scaleX
end