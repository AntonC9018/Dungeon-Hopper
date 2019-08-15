local Turn = class("Turn")

function Turn:__construct(a, actor, ...)
    -- the action 
    self.a = a
    -- initial values
    self.initial = {
        pos = actor.pos,
        facing = actor.facing
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
    self.actor.hist:add(self)

    self.final = {
        pos = self.actor.pos,
        facing = self.actor.facing
    }
    
    self._in = true

    return self
end


function Turn:satisfies(...)
    for i = 1, arg.n do
        if not self[arg[i]] then
            return false
        end
    end
    return true
end

function Turn:satisfiesAny(...)
    for i = 1, arg.n do
        if self[arg[i]] then
            return true
        end
    end
    return false
end

return Turn