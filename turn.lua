-- an abstraction for any single movement of an entity

Turn = constructor:new{}

-- inited before the action has been registered
function Turn:new(s, a)
    local o = constructor.new(self, {})

    -- the action (typically just a vector)
    o.a = a
    -- initial position
    o.i_pos = { x = s.x, y = s.y }
    -- initial facing direction
    o.i_facing = s.facing
    -- the subject of the action
    o.s = s

    return o
end

function Turn:setResult(...)
    for i = 1, arg.n do
        self[arg[i]] = true
    end
    -- final position (after the movement)
    self.f_pos = { x = self.s.x, y = self.s.y }
    -- final facing
    self.f_facing = self.s.facing

    self._set = true
end


function Turn:setResponse(r)
    self.r = r
end

function Turn:was(code)
    for i = 1, #self do
        if self[i][code] then return true end
    end
    return false
end