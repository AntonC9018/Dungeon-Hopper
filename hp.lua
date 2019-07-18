
RED = 1
BLUE = 2
BLACK = 3

EMPTY = 0
HALF = 1
FULL = 2

DEAD = 0
ALIVE = 1


HPContainer = Animated:new{}

-- function HPContainer:new(...)
--     local o = Animated.new(self, ...)

--     return o
-- end


function HPContainer:createSprite()
end


function HPContainer:set()
end

function HPContainer:add(am)
    local residue = am + self.full - EMPTY
    if residue >= 0 then
        self.full = FULL
        return residue
    else
        self.full = am
        return 0
    end
end

function HPContainer:sub(am)
    local residue = self.full - am
    if residue <= 0 then
        self.full = EMPTY
        return -residue
    else
        self.full = self.full - am
        return 0
    end
end

function HPContainer:rmv()
    -- TODO: emit the event
end

function HPContainer:empty()
end

function HPContainer:__tostring()
    return  ((self.full == EMPTY and '○') or (self.full == HALF and '◐') or '●')
end

HP = constructor:new{}

function HP:new(...)
    local o = constructor.new(self, ...)
    o.cs = {}
    return o
end

function HP:set(type, am)
    for i = 1, am do
        self.cs[i] = HPContainer:new({ type = type, full = FULL })
    end
    return self
end

function HP:add(type, am)
    for i = 1, am do
        table.insert(self.cs, HPContainer:new({ type = type, full = FULL }))
    end
    return self
end

function HP:rmv(type, am)
    local j = 0
    for i = #self.cs, 1, -1 do
        if self.cs[i].type == type then
            self.cs:rmv()
            table.remove(self.cs, i)
            j = j + 1
        end
        if j == am then return ALIVE, #self.cs end
    end
    if #self.cs == 0 then return DEAD, 0 end
end

-- take X amount of damage
function HP:take(dmg)
    for i = #self.cs, 2, -1 do
        dmg = self.cs[i]:sub(dmg)
        if dmg <= 0 then return ALIVE, 0 end
    end
    dmg = self.cs[1]:sub(dmg)
    if dmg <= 0 and self.cs[1].full ~= EMPTY then return ALIVE, 0 
    else return DEAD, dmg end
end


function HP:heal(am)
    for i = 1, #self.cs do
        am = self.cs[i]:add(am)
        if am <= 0 then return 0 end
    end
    return amount
end

function HP:resetSprites()
    for i = 1, #self.cs do
        self.cs[i].sprite:setFrame(self.cs[i].full + 1)
    end
end

function HP:isFull(cs)
    for i = 1, #self.cs do
        if self.cs[i] ~= FULL then return false end
    end
    return true
end

function HP:isEmpty(cs)
    for i = 1, #self.cs do
        if self.cs[i] ~= EMPTY then return false end
    end
    return true
end

function HP:__tostring()
    local s = 'Hearts: '
    for i = #self.cs, 1, -1 do
        s = s..self.cs[i]:__tostring()..' '
    end
    return s
end