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
    for key, value in pairs(self.stats) do
        if self.stats[key] > 0 then
            self.stats[key] = value - 1
        end
    end
    return self
end

function Stats:updateTo(stats)
    for k, v in pairs(stats.stats) do
        self.stats[k] = v
    end
end

function Stats:addStats(stats)
    for key, value in pairs(stats.stats) do
        self.stats[key] = value
    end
end


function Stats:__unm()
    local stats = Stats()
    for key, value in pairs(self.stats) do
        newStats.stats[key] = -value
    end
    return stats
end

return Stats
