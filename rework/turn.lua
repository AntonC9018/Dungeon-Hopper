local Turn = class("Turn")

function Turn:__construct(a, actor, ...)
    -- the action a (vector)
    self.a = a
    -- initial values
    self.i = {
        p = actor.pos,
        f = actor.facing
    }
    -- the actor
    self.actor = actor
    -- any other arguments
    self.args = ...
end


function Turn:set(...)
    for i = 1, arg.n do
        self[arg[i]] = true
    end

    self._set = true

    return self
end


function Turn:apply()
    if not self._set or self._in then return self end
    self.actor.history:add(self)

    self.f = {
        p = self.actor.pos,
        f = self.actor.facing
    }
    
    self._in = true

    return self
end

return Turn