-- Rotates a vector half Pi radians TO THE RIGHT
function rotateHalfPi(v)
    return { v[2], -v[1] }
end


function dot(v, i, j)
    -- i and j are the basis vectors of their matrix
    -- v is the vector to which multiply the matrix
    return { 
        i[1] * v[1] + j[1] * v[2],
        i[2] * v[1] + j[2] * v[2]    
    }
end


function inner(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2]
end

function det(i, j)
    return i[1] * j[2] - i[2] * j[1]
end

function angleBetween(v1, v2)
    return math.atan2(det(v1, v2), inner(v1, v2))
end


function normalize(v)
    local length = Math.sqrt(v[1]^2 + v[2]^2)
    v[1] = v[1] / length
    v[2] = v[2] / length
    return v
end


function normComps(v)
    v[1] = sign(v[1])
    v[2] = sign(v[2])
    return v
end


function contains(table, val)
    for i = 1, #table do
        if table[i] == val then 
           return true
        end
    end
    return false
end


function sign(x)
  return (x < 0 and -1) or ((x > 0 and 1) or 0)
end


function mul(v, a)
    v[1] = v[1] * a
    v[2] = v[2] * a
    return v
end


function mulCopy(v, a)
    return { v[1] * a, v[2] * a }
end


function addVecCopy(v1, v2)
    return { v1[1] + v2[1], v1[2] + v2[2] }
end


function addCopy(v, a)
    return { v[1] + a, v[2] + a }    
end


table.all = function(arr, it)
    for i = 1, #arr do
        if arr[i] ~= it then return false end
    end
    return true
end


table.some = function(arr, it)
    for i = 1, #arr do
        if arr[i] == it then return true end
    end
    return false
end


function isBlocked(x, y, w)
    return w.walls[x][y] or w.entities_grid[x][y]
end


function areBlocked(arr, w)
    for i = 1, #arr do
        if isBlocked(arr[i][1], arr[i][2], w) then return true end
    end
    return false
end


function havePlayer(arr, w)
    for i = 1, #arr do
        if w.entities_grid[arr[i][1]][arr[i][2]] == w.player then return true end
    end
    return false
end