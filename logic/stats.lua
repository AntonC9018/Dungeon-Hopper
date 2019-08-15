local Stats = class('Stats')

function Stats:__construct(o)
    self.c = {}
    if o then
        local t = o.c or o
        for k, v in pairs(t) do
            self.c[k] = v
        end
    end
end

Stats.__add[Stats] = function(self, rhs)
    local s = Stats(self)
    for k, v in pairs(rhs.c) do
        if not s.c[k] then s.c[k] = 0 end
        s.c[k] = s.c[k] + v
    end
    return s
end

Stats.__sub[Stats] = function(self, rhs)
    local s = Stats(self)
    for k, v in pairs(rhs.c) do
        if not s.c[k] then s.c[k] = 0 end
        s.c[k] = s.c[k] - v
    end
    return s
end

-- keep only those values, that are positive in rhs
Stats.__mul[Stats] = function(self, rhs)
    local s = Stats(self)
    for k, v in pairs(self.c) do
        if not rhs.c[k] or rhs.c[k] > 0 then
            s.c[k] = v
        end
    end
    return s
end

function Stats:get(stat)
    return stat and (self.c[stat] or 0) or self.c
end

function Stats:incStat(stat, v)
    if self.c[stat] then
        self.c[stat] = self.c[stat] + v
    else
        self.c[stat] = v
    end
    return self.c[stat]
end

function Stats:setStat(stat, v)    
    self.c[stat] = v
    return self.c[stat]
end

function Stats:inc(val)
    for k, v in pairs(self.c) do
        if not self.c[k] then self.c[k] = 0 end
        self.c[k] = self.c[k] + val
    end
    return self
end

function Stats:llim(val)
    for k, v in pairs(self.c) do
        if not self.c[k] then self.c[k] = 0 end
        if self.c[k] < val then
            self.c[k] = val
        end
    end
    return self
end

return Stats