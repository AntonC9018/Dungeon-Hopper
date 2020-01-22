local Stats = class("Stats")


function Stats:__construct()
    self.stats = {}
end


function Stats:set(name, value)
    self.stats[name] = value
    return self.stats[name]
end


function Stats:get(name)
    if self.stats[name] == nil then
        return 0
    end
    return self.stats[name] 
end


function Stats:setIfHigher(name, value)
    if 
        self.stats[name] == nil
        or self.stats[name] < value
    then
        self.stats[name] = value
    end
    return self.stats[name]
end


function Stats:mingle(stats)
    for key, value in pairs(stats.stats) do
        self:setIfHigher(key, value)
    end
    return self
end


function Stats:clone()
    local stats = Stats()
    for key, value in pairs(self.stats) do
        stats.stats[key] = value 
    end
    return stats
end


function Stats:decrement()
    for key, value in self.stats do
        if self.stats[key] > 0 then
            self.stats[key] = value - 1
        end
    end
    return self
end


return Stats
