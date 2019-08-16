local Stats = require('logic.stats')

local Modifiable = class('Modifiable')

Modifiable.id = 0

function Modifiable:__construct(base)
    self.mods = {}
    self.stats = false
    if base then
        self:add(base)
    end
    self.id = Modifiable.id
    Modifiable.id = Modifiable.id + 1
end

function Modifiable:add(...)
    self.stats = false
    for i = 1, arg.n do
        -- got a modifiable
        if class.name(arg[i]) == 'Modifiable' then
            for j = 1, #arg[i].mods do
                table.insert(self.mods, arg[i].mods[j])
            end
        -- got a stats object
        elseif class.name(arg[i]) == 'Stats' then
            table.insert(self.mods, arg[i])

        else
            error('Unexpected argument '..tostring(arg[i]))
        end
    end
    return self
end

Modifiable.__sub[Modifiable] = function(self, rhs)
    return self:getStats() - rhs:getStats()
end

Modifiable.__add[Modifiable] = function(self, rhs)
    return self:getStats() + rhs:getStats()
end

-- define some convenient ops for Stats
Stats.__sub[Modifiable] = function(self, rhs)
    return self - rhs:getStats()
end

Stats.__add[Modifiable] = function(self, rhs)
    return self + rhs:getStats()
end


Modifiable.__mul[Stats] = function(self, rhs)
    return self:getStats() * rhs
end

function Modifiable:getStats()
    if self.stats then return self.stats end
    self.stats = Stats()
    for i = 1, #self.mods do
        self.stats = self.stats + self.mods[i]
    end
    return self.stats
end

function Modifiable:get(code)
    return self:getStats():get(code)
end

function Modifiable:empty()
    self.mods = {}
end

return Modifiable