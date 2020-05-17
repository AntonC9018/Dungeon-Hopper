local Dir = require 'world.generation.dir'
local inverseMap = require 'world.generation.dirsmap'

local map = {}
map['01'] = 1
map['10'] = 2
map['21'] = 3
map['12'] = 4


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

return function(x, y, w, h)
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