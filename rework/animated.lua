local Animated = class('Animated', Displayable)

-- function Animated:__construct(anims)
--     self.anims = anims
-- end

function Animated:playAnimation(w, callback)
    local l = w:getAnimLength()
    local ts = l / (#self.hist == 0 and 1 or #self.hist)

    local function _callback()
        -- if self.dead then
        --     self:_die()
        -- else
        --     self:_idle()
        -- end
        -- self.emitter:emit('animation:end', self, w)
        if callback then callback() end
    end

    local function doIteration(i)

        local cb = function() doIteration(i + 1) end
        local t = self.history[i]

        if t then

            -- TODO:rework
            if t.f.facing.x ~= 0 then
                self:orient(t.f.facing.x)
            end

            for j = 1, #self.anims do
                if t:satisfies(unpack(self.anims[j].c)) then
                    return self[self.anims[j].a](t, ts, cb)
                end
            end

            -- no match
            cb()

        else
            _callback()
        end
    end

    -- start the animations
    doIteration(1)
end

return Animated