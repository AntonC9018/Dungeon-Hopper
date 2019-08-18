local Displayable = require('base.displayable')

local Animated = class('Animated', Displayable)

-- function Animated:__construct(anims)
--     self.anims = anims
-- end

Animated.offset = vec(0, -0.3)
Animated.offset_y_jump = -0.2
Animated.offset_y_hop = -0.2



function Animated:playAnimation(callback)

    -- printf('%s is playing animation. History length: %d', class.name(self), #self.hist:arr())

    local l = self.world:getAnimLength()
    local h = self.hist:arr()

    local ts = l / (#h == 0 and 1 or #h)

    self:emit('animation', 'start')

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

        local t = h[i]
        

        local cb = function()
            self:emit('animation', 'step:complete', t, i)
            doIteration(i + 1)
        end

        if t then
            self:emit('animation', 'step:start', t, i)

            -- TODO:rework
            if t.final.facing.x ~= 0 then
                self:orient(t.final.facing.x)
            end

            for j = 1, #self.anims do
                if t:satisfies(unpack(self.anims[j].c)) then
                    return self[self.anims[j].a](self, t, ts, cb)
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


-- standart functions of animations
function Animated:_displaced(t, ts, cb, a)
    self:anim(ts, a or 'jump')
    -- this animation consists of two steps
    -- first is the first half - jumping up
    transition.to(self.sprite, {
        x = (t.final.pos.x + t.initial.pos.x) / 2 + (self.size and (self.size.x / 2) or 0),
        y = (t.final.pos.y + t.initial.pos.y) / 2 + (self.size and (self.size.y / 2) or 0) + self.offset.y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.linear,
        onComplete = function()
            -- falling down
            transition.to(self.sprite, {
                x = t.final.pos.x + (self.size and (self.size.x / 2) or 0),
                y = t.final.pos.y + (self.size and (self.size.y / 2) or 0) + self.offset.y,
                time = ts / 2,
                transition = easing.linear,
                onComplete = function()
                    if cb then cb() end
                end
            })
        end
    })
end

function Animated:_displacedHit(t, ts, cb)
    self:_displaced(t, ts, cb)
    self:_hit(t, ts)
end

function Animated:_displacedHurt(t, ts, cb)
    self:_displaced(t, ts, cb)
    self:_hurt(t, ts)
end

function Animated:_hurt(t, ts, cb, a)
    self:anim(ts, a or 'hurt')
    self:playAudio('hurt')
    if cb then cb() end
end

function Animated:_bumped(t, ts, cb, a)
    self:anim(ts, a or 'jump')
    transition.to(self.sprite, {
        x = t.initial.pos.x + t.a.dir.x / 2 + (self.size and (self.size.x / 2) or 0),
        y = t.initial.pos.y + t.a.dir.y / 2 + (self.size and (self.size.y / 2) or 0) + self.offset.y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

function Animated:_hurtBumped(t, ts, cb)
    self:_bumped(t, ts, cb)
    self:_hurt(t, ts)
end

function Animated:_hit(...)
    self:_bumped(unpack(arg))
end

function Animated:_idle(t, ts, cb, a)
    self:anim(1000, a or 'idle')
    if cb then cb() end
end

function Animated:_hopUp(t, ts, cb)
    transition.to(self.sprite, {
        x = t.final.pos.x + (self.size and (self.size.x / 2) or 0),
        y = t.final.pos.y + (self.size and (self.size.y / 2) or 0) + self.offset.y + self.offset_y_hop,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

function Animated:_hit(t, ts, cb)
    if self.weapon then
        self.weapon:playAnimation(t, ts)
        self.weapon:playAudio()
    end
    if cb then cb() end
end

return Animated