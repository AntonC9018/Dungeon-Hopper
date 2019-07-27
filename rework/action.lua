local Action = class('Action')

function Action:__constuct(actor, code, ...)
    self.actor = actor
    self.code = code
    self.args = ...
end


function Action:setAtt(att)
    self.att = att
    return self
end

function Action:setAms(ams)
    self.ams = ams
    return self
end

function Action:setDir(dir)
    self.dir = dir
    return self
end

function Action:setSpecial(s)
    self.special = s
end

function Action:copy()
    return Action(self.actor, self.code)
        :setDir(self.dir)
        :setAms(self.ams)
        :setSpecial(self.special)
        :setAtt(self.att)
end


Action.toActions = function(a, c, arr)
    local s = {}
    for i = 1, #arr do
        s[i] = Action(a, c):setDir(arr[i])
    end
    return s
end

Action.each = function(arr, cmd, val)
    for i = 1, #arr do
        arr[i][cmd](val)
    end
    return arr
end

Action.eachBoth = function(arr, cmd, arr2)
    for i = 1, #arr do
        arr[i][cmd](arr2[i])
    end
    return arr
end



return Action