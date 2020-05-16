
-- The idea is to keep track of free sections
-- Whenever a room needs to be generated, take the smallest
-- section that can hold it and place the room somewhere within that segment
-- After that, update the list of free segments
-- Repeat, until a grid has been generated

local MAX_ITER = 10000

local function Dir(x, y)
    return { x = x, y = y }
end

local map = {}
map['01'] = 1
map['10'] = 2
map['21'] = 3
map['12'] = 4

local inverseMap = {
    Dir(-1, 0),
    Dir(0, -1),
    Dir(1, 0),
    Dir(0, 1)
}

local function toIndex(dir)
    local t = tostring(dir.x + 1)..tostring(dir.y + 1)
    return map[t]
end

local function toIndexNeg(dir)
    local t = tostring(-dir.x + 1)..tostring(-dir.y + 1)
    return map[t]
end

local node_mt = {
    __index = {        
        setNeighbor = function(node, dir, neigh)
            node .neighbors[toIndex(dir)]    = neigh
            neigh.neighbors[toIndexNeg(dir)] = node
        end,
        getNeighbor = function(node, dir)
            return node.neighbors[toIndex(dir)]
        end,
        clearNeighbor = function(node, dir)
            node.neighbors [toIndex(dir)] = nil
        end,
        getOccupiedDirections = function(node)
            local result = {}
            for i, v in pairs(inverseMap) do
                if node.neighbors[i] then
                    table.insert(result, v)
                end
            end
            return result
        end
    }
}

local function Node(x, y, w, h)
    local obj = {
        x = x,
        y = y,
        w = w,
        h = h,
        neighbors = {}
    }
    setmetatable(obj, node_mt)
    return obj
end

local function Room(x, y, w, h)
    return {
        x = x,
        y = y,
        w = w,
        h = h
    }
end


local Generator = class("WorldGenerator")

function Generator:randomDir()
    local i = math.random(4)
    return inverseMap[i]
end

function Generator:randomDirOtherThan(dirs)
    if dirs[1] == nil then dirs = {dirs}
    elseif #dirs == 4 then return nil
    elseif #dirs == 3 then
        -- add them up
        local x, y = 0, 0
        for _, dir in ipairs(dirs) do
            x, y = x + dir.x, y + dir.y
        end
        -- negate the result
        return Dir(-x, -y)
    end
    -- generate a random dir, until not in set
    local r_dir

    local function has()
        for _, dir in ipairs(dirs) do
            if dir.x == r_dir.x and dir.y == r_dir.y then
                return true
            end
        end
        return false
    end

    repeat
        r_dir = self:randomDir()
    until not has()

    return r_dir
end

function Generator:isOccupiedPosInGraph(x, y)
    if x > self.width then
        return true
    end
    if y > self.height then
        return true
    end
    return self.graphMap[x][y] ~= nil
end

function Generator:generateNode(parentNode)
    local w = math.random(7, 9)
    local h = math.random(7, 9)
    local dirs = parentNode:getOccupiedDirections()
    repeat
        local dir = self:randomDirOtherThan(dirs)
        local x = parentNode.x + dir.x
        local y = parentNode.y + dir.y
        if self:isOccupiedPosInGraph(x, y) then
            table.insert(dirs, dir)
            if #dirs == 4 then
                print('ALl directions occupied')
                return nil
            end
        else
            local node = Node(x, y, w, h)
            self.graphMap[x][y] = node
            parentNode:setNeighbor(dir, node)
            return node
        end
    until true
end


function Generator:__construct(w, h)
    self.width = w
    self.height = h
    self.grid = {}
    for i = 1, w do
        self.grid[i] = {}
    end

    -- so the idea is to generate a graph where
    -- the root node is the starting room
    local startRoomWidth = 6
    local startRoomHeight = 6
    self.rootNode = Node(3, 3, startRoomWidth, startRoomHeight)

    -- use a graph map to easily search for neihboring nodes
    self.graphMap = {}
    for i = 1, 5 do
        self.graphMap[i] = {}
    end
    self.graphMap[3][3] = self.rootNode
    
    local room1 = self:generateNode(self.rootNode)
    local room2 = self:generateNode(self.rootNode)
    local room1_1 = self:generateNode(room1)
    local room1_2 = self:generateNode(room1)
    local room2_1 = self:generateNode(room2)

    self:generate()
end


function Generator:print()
    for j = 1, self.height do
        local str = ''
        for i = 1, self.width do
            if self.grid[i][j] == nil then
                str = str..'. '
            else
                str = str..self.grid[i][j].type..' '
            end
        end
        print(str)
    end
end

local Types = {
    WALL = 'w',
    TILE = 't',
    HALLWAY = 'e',
    RESTRICTED = 'r'
}

local function Cell(type, room)
    return {
        type = type,
        room = room
    }
end

function Generator:writeIn(room)
    -- write the outside with walls
    for i = 0, room.w - 1 do
        self.grid[room.x + i][room.y]              = Cell(Types.WALL, room)
        self.grid[room.x + i][room.y + room.h - 1] = Cell(Types.WALL, room)
    end
    for j = 1, room.h - 1 do
        self.grid[room.x][room.y + j]              = Cell(Types.WALL, room)
        self.grid[room.x + room.w - 1][room.y + j] = Cell(Types.WALL, room)
    end
    -- fill in the center
    for x = room.x + 1, room.x + room.w - 2 do
        for y = room.y + 1, room.y + room.h - 2 do
            self.grid[x][y] = Cell(Types.TILE, room)
        end
    end
end

function Generator:iterate(parentNode, parentRoom, ignoreNode)
    for _, dir in ipairs(parentNode:getOccupiedDirections()) do
        -- construct the node itself
        local node = parentNode:getNeighbor(dir)
        if node ~= ignoreNode then
            local room = self:placeRoom(node, parentRoom, dir)
            if room ~= nil then
                self:iterate(node, room, parentNode)
            end
        end
    end
end

function Generator:generate()
    
    local startX = math.round((self.width - self.rootNode.w) / 2)
    local startY = math.round((self.height - self.rootNode.h) / 2)
    -- write the tiles in
    local startRoom = Room(startX, startY, self.rootNode.w, self.rootNode.h)
    self:writeIn(startRoom)
    
    self:iterate(self.rootNode, startRoom)

    self:pruneGrid()
    self:print()
end

function Generator:pruneGrid()
    for i = 1, self.width do
        if self.grid[i] == nil then
            print("Weird bug for i = ", i)
            self.grid[i] = {}
        end
    end
    local min_x
    for x = 1, self.width do
        for y = 1, self.height do
            if self.grid[x][y] ~= nil then
                min_x = x
                break
            end
        end
        if min_x ~= nil then
            break
        end
    end

    local min_y
    for y = 1, self.height do
        for x = 1, self.width do
            if self.grid[x][y] ~= nil then
                min_y = y
                break
            end
        end
        if min_y ~= nil then
            break
        end
    end

    local max_x
    for x = self.width, 1, -1 do
        for y = self.height, 1, -1 do
            if self.grid[x][y] ~= nil then
                max_x = x
                break
            end
        end
        if max_x ~= nil then
            break
        end
    end

    local max_y
    for y = self.height, 1, -1 do
        for x = self.width, 1, -1 do
            if self.grid[x][y] ~= nil then
                max_y = y
                break
            end
        end
        if max_y ~= nil then
            break
        end
    end

    local newGrid = {}
    self.width = max_x - min_x + 1
    self.height = max_y - min_y + 1
    for i = 0, self.width - 1 do
        newGrid[i + 1] = {}
        for j = 0, self.height - 1 do
            newGrid[i + 1][j + 1] = self.grid[min_x + i][min_y + j]
        end
    end

    self.grid = newGrid
end

function Generator:getCell(pos)
    if (pos.x > self.width) or (pos.y > self.height) or (pos.x < 1) or (pos.y < 1) then
        return Cell(Types.RESTRICTED)
    end 
    if self.grid[pos.x] == nil then
        print('The weird bug took place at pos = ', pos.y)
        self.grid[pos.x] = {}
    end
    return self.grid[pos.x][pos.y]
end

function Generator:placeRoom(node, parent, dir)
    
    -- get the minimum coordinate of the start of the room depending
    -- on the direction on the position of the parent room
    local dirVec =    Vec(dir.x, dir.y)
    local angle =     -Vec.angleBetween(Vec(1, 0), dirVec)
    local parentStart =   Vec(parent.x, parent.y)
    local parentCenter =  Vec(parent.w - 1, parent.h - 1) / 2 + parentStart
    local leftTopOffset = -Vec(parent.w - 1, parent.h - 1) / 2

    local relRoomDim =   Vec(node.w, node.h)     :rotate(angle)
    local relParentDim = Vec(parent.w, parent.h) :rotate(angle)
    
    local relRightVec = dirVec
    local relDownVec  = dirVec:rotate(-math.pi / 2)

    local d = Vec(parent.w - 1, parent.h - 1)
    local relParentWidthVec =  d * relRightVec
    local relParentHeightVec = d * relDownVec

    d = Vec(node.w - 1, node.h - 1)
    local relRoomWidthVec =  d * relRightVec
    local relRoomHeightVec = d * relDownVec
    
    local mirror_x = dir.y == 1 or dir.x == -1
    local mirror_y = dir.y == -1  or dir.x == -1
    local mirr = Vec(mirror_x and -1 or 1, mirror_y and -1 or 1)

    local relParentStart = leftTopOffset * mirr + parentCenter
    local relRoomStart   = relParentStart + relParentWidthVec

    -- self.grid[relParentStart.x][relParentStart.y] = { type = 'p'}
    -- self.grid[relRoomStart.x][relRoomStart.y] = { type = 's'}
    -- self.grid[relParentEnd.x][relParentEnd.y] = { type = 'r'}
    -- return nil
    -- get a random offset. The offset is limited by the size 
    -- of the room. The offset is like how far to the right or to the 
    -- left (top or bottom) of the center of the room the hallway is
    local max_var_top = -math.abs(relRoomDim.y)  + 3
    local max_var_bot = math.abs(relParentDim.y) - 3
    local min_hallway_length = 2
    local max_hallway_length = 5

    -- generate a random offset based on variation and place the room
    -- if can't place the room with that variation, try another
    local hallOffsetStart = math.random(min_hallway_length, max_hallway_length)
    local perpOffsetStart = math.random(max_var_top, max_var_bot)

    local currentHallOffset = hallOffsetStart
    local currentPerpOffset = perpOffsetStart

    local currentHallTestSign = 1
    local currentPerpTestSign = 1

    -- check if can place the room at those coordinates.
    -- for that, all coordinates must be unoccupied with other rooms
    -- TODO: ideally, we should be able to check that just by checking 
    -- the outer edges or event the corners
    -- for now, walk the entire space over and over. if found a cell
    -- other than nil or occupied by a wall, test another offset
    local currentHallOffsetVec
    local currentPerpOffsetVec
    local currentStart
    local valid
    repeat
        valid = true
        currentHallOffsetVec = relRightVec * currentHallOffset
        currentPerpOffsetVec = relDownVec * currentPerpOffset
        currentStart = relRoomStart + currentPerpOffsetVec + currentHallOffsetVec
        for i = -currentHallOffset, relRoomWidthVec:mag() do
            for j = 0, relRoomHeightVec:mag() do
                local pos = currentStart + i * relRightVec + j * relDownVec
                self:getCell(pos)
                if cell ~= nil then
                    if cell.type ~= Types.WALL then
                        valid = false
                        break
                    end
                end
            end
            if not valid then
                currentHallOffset = currentHallOffset + currentHallTestSign
                if currentHallTestSign == 1 then
                    if currentHallOffset > max_hallway_length then
                        currentHallOffset = hallOffsetStart - 1
                        currentHallTestSign = -1
                    end
                end
                if currentHallTestSign == -1 then
                    if currentHallOffset < min_hallway_length then
                        currentHallOffset = hallOffsetStart
                        currentHallTestSign = 1

                        currentPerpOffset = currentPerpOffset + currentPerpTestSign

                        if currentPerpOffset > max_var_bot then
                            currentPerpOffset = perpOffsetStart - 1
                            currentPerpTestSign = -1
                        end
                        if currentPerpOffset < -max_var_top then
                            print('No place for a room')
                            return nil
                        end
                    end
                end
                
                break
            end
        end
    until valid


    -- once found a spot, fill it in
    -- local relHalfRoomDimMinusOne = Vec(room.x - 1, room.h - 1):rotate(angle) / 2
    local roomCenter = currentStart + relRoomWidthVec / 2 + relRoomHeightVec / 2
    local leftTopRoomOffset = -relRoomWidthVec / 2 - relRoomHeightVec / 2
    local neededPos = roomCenter + leftTopRoomOffset * mirr
    local room = Room(neededPos.x, neededPos.y, node.w, node.h)
    self:writeIn(room)
    self.grid[room.x][room.y] = { type = 'g' }
    -- get a random hallway offset
    -- if the new room is lower than the parent room, do
    -- [[ lower left corner of the parent room minus upper left of the new room ]]
    -- if the new room is higher but its bottom left corner does not reach
    -- past the bottom of the parent room do
    -- [[ upper right corner of the parent room minus top left corner of the new room ]]
    -- otherwise it goes past the bottom of the second room, so the variance
    -- [[ will be the relative height of the parent room ]]
    -- The parameter displaying their relative position is currentPerpOffset
    
    local hallwayPos

    -- the first case
    if currentPerpOffset > 0 then
        -- it is one past the corner
        local lowerLeftParent = relParentStart + relParentHeightVec
        -- the difference is one more bigger than needed
        -- so it's 2 more than needed right now
        local perpDiff = lowerLeftParent - currentStart
        -- this also has the relative x component, so project onto y
        local projDiff = perpDiff * relDownVec
        -- get the length and subtract 2
        -- although it can be deduced as simply x + y, since the projected
        -- vector is pure x or y, just calculate the magnitude
        local mag = projDiff:mag()
        local variance = mag - 1
        -- generate the start vector
        local offset = math.random(1, variance)
        
        hallwayPos = currentStart + offset * relDownVec

    else
        -- still, one past the corner
        local lowerLeftRoom = currentStart + relRoomHeightVec
        -- calculate the difference
        local perpDiff = relParentStart - lowerLeftRoom
        -- project
        local projDiff = perpDiff * relDownVec
        -- get manitude
        local mag = projDiff:mag()
        -- get the relative height magnitude
        local relHeightMag = relParentHeightVec:mag()

        local variance
        if mag > relHeightMag then
            variance = relHeightMag - 1
        else
            variance = mag - 1
        end

        local offset = math.random(1, variance)

        hallwayPos = 
            relParentStart 
            + offset * relDownVec 
            + relParentWidthVec 
            + relRightVec * currentHallOffset

    end

    -- generate hallway
    for i = 0, currentHallOffset do
        local currentHallPos = hallwayPos + -i * dirVec
        self.grid[currentHallPos.x][currentHallPos.y] = Cell(Types.HALLWAY, { parent, node })
        local wallTopPos = currentHallPos + relDownVec
        self.grid[wallTopPos.x][wallTopPos.y] = Cell(Types.WALL, { parent, node })
        local wallBotPos = currentHallPos - relDownVec
        self.grid[wallBotPos.x][wallBotPos.y] = Cell(Types.WALL, { parent, node })
    end

    return room
end


return Generator