EMPTY = 0
HALF = 1
FULL = 2


local HPContainer = class('HPContainer')

function HPContainer:__construct(type, f)
    self.f = f
    self.t = type
end

function HPContainer:add(am)
    local ex = self.f + am - 2
    if ex >= 0 then
        self.f = 2
        return ex
    else
        self.f = ex
        return 0
    end
end

function HPContainer:sub(am)
    local ex = self.f - am
    if ex <= 0 then
        self.f = 0
        return -ex
    else
        self.f = ex
        return 0
    end
end

function HPContainer:rmv() end

function HPContainer:__tostring()
    return  ((self.f == EMPTY and '○') or (self.f == HALF and '◑') or '●')
end

local HP = class('HP')

function HP:__construct(b)
    self.c = {}
    self:set(b.t, b.am)
end

function HP:set(type, am)
    local c = {}
    for i = 1, am do
        c[i] = HPContainer(type, 2)
    end
    self.c = c
    return self
end

function HP:add(type, am)
    for i = 1, am do
        table.insert(self.c, HPContainer(type, 2))
    end
    return self
end

function HP:rmv(type, am)
    local j = 0
    for i = #self.c, 1, -1 do
        if self.c[i].type == type then
            self.c:rmv()
            table.remove(self.c, i)
            j = j + 1
        end
        if j == am then return 'alive', #self.c end
    end
    if #self.c == 0 then return 'dead', 0 end
end

-- take X amount of damage
function HP:take(dmg)
    for i = 1, #self.c do
        dmg = self.c[i]:sub(dmg)
        if dmg < 0 then return 0 end
    end
    return dmg
end


function HP:heal(am)
    for i = 1, #self.c do
        am = self.c[i]:add(am)
        if am <= 0 then return 0 end
    end
    return am
end

function HP:resetSprites()
    for i = 1, #self.c do
        self.c[i].sprite:setFrame(self.c[i].full + 1)
    end
end

function HP:isFull()
    for i = 1, #self.c do
        if self.c[i] ~= FULL then return false end
    end
    return true
end

function HP:isEmpty()
    for i = 1, #self.c do
        if self.c[i] ~= EMPTY then return false end
    end
    return true
end

function HP:__tostring()
    local s = 'Hearts: '
    for i = #self.c, 1, -1 do
        s = s..self.c[i]:__tostring()..' '
    end
    return s
end

return HP, HPContainer