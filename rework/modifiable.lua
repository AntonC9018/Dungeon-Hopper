local Modifiable = class('Modifiable')

Modifiable.id = 0

function Modifiable:__construct(base)
    self.mods = {}
    if base then
        self:add(base)
    end
    self.id = Modifiable.id
    Modifiable.id = Modifiable.id + 1
end

function Modifiable:add(...)
    for i = 1, arg.n do
        -- Go a modifiable
        if class.name(arg[i]) == 'Modifiable' then
            for j = 1, #arg[i].mods do
                table.insert(self.mods, arg[i].mods[j])
            end
        -- got a stats object
        elseif class.name(arg[i] == 'Stats') then
            table.insert(self.mods, arg[i])
        
        else    
            error('Unexpected argument '..tostring(i))
        end
    end
    return self
end

Modifiable._sub[Modifiable] = function(self, rhs)
    return self:getStats() - rhs:getStats()
end

Modifiable._add[Modifiable] = function(self, rhs)
    return self:getStats() + rhs:getStats()
end

function Modifiable:getStats()
    local result = Stats()
    for i = 1, #self.mods do
        result = result + self.mods[i]
    end
    return result
end

function Modifiable:empty()
    self.mods = {}
end