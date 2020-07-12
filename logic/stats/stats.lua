local Stats = class("Stats")


function Stats:__construct()
    self.stats = {}
end


Stats.fromTable = function(t)
    local stats = Stats()
    if t == nil then
        return stats
    end
    for key, value in pairs(t) do
        stats:set(key, value)
    end
    return stats
end

function Stats:isSet(name)
    return self.stats[name] ~= nil
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

function Stats:add(name, amount)
    if self.stats[name] == nil then
        self.stats[name] = amount
    else
        self.stats[name] = self.stats[name] + amount
    end
end


function Stats:clone()
    local stats = Stats()
    for key, value in pairs(self.stats) do
        stats.stats[key] = value 
    end
    return stats
end

function Stats:updateTo(stats)
    for k, v in pairs(stats.stats) do
        self.stats[k] = v
    end
end

function Stats:addStats(stats)
    for key, value in pairs(stats.stats) do
        self:add(key, value)
    end
end


function Stats:__unm()
    local stats = Stats()
    for key, value in pairs(self.stats) do
        stats.stats[key] = -value
    end
    return stats
end

return Stats
