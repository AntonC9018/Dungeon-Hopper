local CyclicBuffer = class('CyclicBuffer')

function CyclicBuffer:__construct(size)
    self.size = size
    self.length = 0
    self.clock = 1
    self.items = {}
    self.excess = {}
end


function CyclicBuffer:advanceClock(x)
    self.clock = self.clock + x - 1
    self.clock = (self.clock % self.size) + 1
end


function CyclicBuffer:addItem(item)
    local existingItem = self.items[self.clock]

    if existingItem ~= nil then
        table.insert(self.excess, existingItem)
    else
        self.length = self.length + 1
    end

    self.items[self.clock] = item

    self:advanceClock(1)
end


function CyclicBuffer:removeExcess()
    local result = self.excess
    self.excess = {}
    return result
end


function CyclicBuffer:increaseSize(size)
    -- if the number of items is less than the clock's position, we
    -- can simply add size, since the clock always points to the segment
    -- of nil, if there are any, which means this empty segment reaches
    -- the end of the array
    if self.length < self.clock then
        self.size = self.size + size
        return
    end    
    -- if the clock is at the start or the buffer is full, 
    -- add size and set it at the current end + 1
    if self.clock == 1 or self.size == self.length then
        self.clock = self.size + 1
        self.size = self.size + size
        return
    end
    -- otherwise, the nil segment is in the middle of the buffer
    -- find out the position of the first element after the clock
    -- which is just the current clock position + number of free spaces
    local free = self.size - self.length
    local elemIndex = self.clock + free
    -- now we need to shift these elements over `size` positions
    -- to the right starting from the end of the buffer
    for i = self.size, elemIndex, -1 do
        self.items[i + size] = self.items[i]
    end
    -- now set `size` positions starting from the first element
    -- after the nil segment to nil
    for i = 0, size - 1 do
        self.items[elemIndex + i] = nil  
    end
    -- finally, increment size
    self.size = self.size + size
end


function CyclicBuffer:removeAt(index)
    -- if no item at index, skip
    if self.items[index] == nil then
        return nil
    end
    local length = self.length
    self.length = self.length - 1
    -- if the buffer is full, remove the item
    -- and set clock to that position
    if length == self.size then
        self.items[index] = nil
        self.clock = index
        return
    end
    -- otherwise, the clock is pointing at some empty segment
    -- if the item removed is to the right of the clock, shift
    -- the items after the empty segment up to the index of the
    -- item removed to the right
    if index > self.clock then
        local free = self.size - length
        local firstEl = self.clock + free
        for i = index, firstEl, -1 do
            self.items[i] = self.items[i - 1]
        end
        return
    end
    -- if the clock's position is to the right of the item being
    -- removed, shift the items staring from the index of that item
    -- to the clock's position, shift from right to left
    for i = index, self.clock - 1 do
        self.items[i] = self.items[i + 1]
    end
    -- turn the clock one position to the left
    self:advanceClock(-1)
end

function CyclicBuffer:removeItem(item)
    for i = 1, self.size do
        if self.items[i] == item then
            return self:removeAt(i)
        end
    end
end

function CyclicBuffer:get(i)
    return self.items[i]
end

function CyclicBuffer:print()
    local skip = (self.clock - 1) * 2 + 1
    printf('%'..tostring(skip)..'s', '|')
    local str = ''
    for i = 1, self.size do
        if self.items[i] == nil then
            str = str..'n '
        else
            str = str..tostring(self.items[i])..' '
        end
    end
    print(str)
end

return CyclicBuffer