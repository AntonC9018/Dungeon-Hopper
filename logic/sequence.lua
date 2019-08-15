local Sequence = class('Sequence')
local Step = require('logic.step')

Sequence.transform = function(s)
    for i = 1, #s do
        s[i] = Step(s[i])
    end
    return s
end

function Sequence:__construct(a)
    self.s = a.seq
    self.count = 1
    self.iter = 0
    self.a = a
end

function Sequence:is(...)
    return self:step():is(...)
end

function Sequence:step()
    return self.s[self.count]
end

function Sequence:tick()

    local s = self:step()
    -- new sequence count
    local nsc

    -- check loop condition. Keep playing if active
    if s.loop and self.a[s.loop](self.a) then
        nsc = self.count
    elseif
        -- check if none are specified
        (not s.escape and not s.iters) or
        -- check the escape condition
        (s.escape and self.a[s.escape](self.a)) or
        -- check the iterations condition
        (s.iters and self.iter >= s.iters) then


        -- figure out what step we will go to
        -- check if a to_step is specified inside p_close or p_close_diagonal
        if self.a.close and s.p_close and s.p_close.to_step then
            nsc = s.p_close.to_step

        elseif self.a.close_diagonal and s.p_close_diagonal and s.p_close_diagonal.to_step then
            nsc = s.p_close_diagonal

        -- check if a to_step is specified outside those
        elseif s.to_step then
            nsc = s.to_step

        -- check if a random step should be used
        elseif s.to_random and #s.to_random > 0 then
            nsc = s.to_random[math.random(1, #s.to_random)]

        -- otherwise just add one
        else
            nsc = self.count + 1
        end


    else
        nsc = self.count + 1
    end

    if nsc ~= self.count then
        self.iter = 0
    else
        self.iter = self.iter + 1
    end

    self.count = nsc > #self.s and (nsc - #self.s) or nsc
end

function Sequence:mov()
    return self:step().mov
end

return Sequence