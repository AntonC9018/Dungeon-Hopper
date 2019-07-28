local Displayable = require('base.displayable')

local Animated = class('Animated', Displayable)

-- function Animated:__construct(anims)
--     self.anims = anims
-- end

Animated.offset_y = -0.3
Animated.offset_y_jump = -0.2



function Animated:playAnimation(callback)
    local l = self.world:getAnimLength()
    local ts = l / (#self.hist == 0 and 1 or #self.hist)
    local h = self.hist:arr()
    

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
        local t = h[i]

        if t then

            -- TODO:rework
            if t.f.f.x ~= 0 then
                self:orient(t.f.f.x)
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
        x = (t.f.p.x + t.i.p.x) / 2 + (self.size and (self.size.x / 2) or 0),
        y = (t.f.p.y + t.i.p.y) / 2 + (self.size and (self.size.y / 2) or 0) + self.offset.y + self.offset_y_jump,
        time = ts / 2,
        transition = easing.linear,
        onComplete = function()
            -- falling down
            transition.to(self.sprite, {
                x = t.f.p.x + (self.size and (self.size.x / 2) or 0),
                y = t.f.p.y + (self.size and (self.size.y / 2) or 0) + self.offset.y,
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
        x = t.i.p.x + t.a.dir.x / 2 + (self.size and (self.size.x / 2) or 0),
        y = t.i.p.y + t.a.dir.y / 2 + (self.size and (self.size.y / 2) or 0) + self.offset.y + self.offset_y_jump,
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
        x = t.f.p.x + (self.size and (self.size.x / 2) or 0),
        y = t.f.p.y + (self.size and (self.size.y / 2) or 0) + self.offset.y + self.offset_y_hop,
        time = ts / 2,
        transition = easing.continuousLoop,
        onComplete = function() if cb then cb() end end
    })
end

return Animated