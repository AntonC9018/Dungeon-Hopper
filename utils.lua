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


function tdArray(w, h, f, reversed)
    if not f then f = function() return false end end

    local arr = {}

    if reversed then

        for i = w, 1, -1 do
            arr[i] = {}        
            for j = h, 1, -1 do
                arr[i][j] = f(i, j)
            end
        end


    else

        for i = 1, w do
            arr[i] = {}        
            for j = 1, h do
                arr[i][j] = f(i, j)
            end
        end

    end

    return arr
end


-- convert a pattern of a weapon's attack or of a spade's dig 
-- into an array of points of impact 
function patternDirToPoints(dir, p, w)
    
    if 
        -- do not waste computing power if the size
        -- can be neglected, which will be the case
        -- in most scenarios
        p.size[1] == 0 and p.size[2] == 0 
    then 
        return { { p.x + dir[1], p.y + dir[2] } }
    end

    if     
        -- or an orthogonal direction
        (math.abs(dir[1]) >= 1 and dir[2] == 0) or
        (math.abs(dir[2]) >= 1 and dir[1] == 0)    
    then    
        -- get the scale of the vector
        local s = dir[1] ~= 0 and math.abs(dir[1]) or math.abs(dir[2]) 
        -- scale it down to have components = 1
        local d = { dir[1] / s, dir[2] / s }
        -- get points out of that
        local ps = p:getPointsFromDirection(d, w)
        -- add to those point that initial vector 

        for i = 1, #ps do
            ps[i][1] = ps[i][1] + (s - 1) * d[1]
            ps[i][2] = ps[i][2] + (s - 1) * d[2]
        end

        return ps
    end

    -- otherwise we have an irregular pattern like that of a whip
    -- or a diagonal direction
    -- this way the algorithm would yield just one point as the result

    -- We don't care about the size while attacking up or to the left
    -- because the player's anchor point is placed at the upper-left corner
    -- However, when doing it to the right or to the bottom, we'll need
    -- to account for that by adding the player's size to the direction

    
    if dir[2] > 0 then
        dir[2] = dir[2] + p.size[2]
    end

    if dir[1] > 0 then
        dir[1] = dir[1] + p.size[1]
    end

    return { { p.x + dir[1], p.y + dir[2] } }
end


function canReach(p, rd, x, y, w) 
    local _x = p.x < x and (p.x + p.size[1]) or p.x
    local _y = p.y < y and (p.y + p.size[2]) or p.y  

    local function cx(__y)
        local dx = x - _x
        if dx ~= 0 then
            local sx = sign(dx)
            for i = sx, sx, dx do
                if 
                    w.walls[_x + i][__y] 
                    -- or 
                    -- (w.entities_grid[_x + i][__y] and w.entities_grid[_x + i][__y]:isObject()) 
                then 
                    return true 
                end
            end
        end
    end

    local function cy(__x)
        local dy = y - _y
        if dy ~= 0 then    
            local sy = sign(dy)        
            for i = sy, sy, dy do
                if 
                    w.walls[__x][_y + i] 
                    --or 
                    -- (w.entities_grid[__x][_y + i] and w.entities_grid[__x][_y + i]:isObject()) 
                then 
                    return true 
                end
            end
        end
    end

    -- rd defines what we should check first. 
    -- check on x-axis first
    if math.abs(rd[1]) > math.abs(rd[2]) then
        if cx(_y) then return false end
        if cy(x) then return false end
    -- check on y-axis
    elseif math.abs(rd[1]) < math.abs(rd[2]) then
        if cy(_x) then return false end
        if cx(y) then return false end

    else 
        -- do a composite check
        -- (some weird diagonal-like pattern)
        -- NOTE: this hasn't been tested
        if dx ~= 0 and dy ~= 0 then
            _x, _y = _x + rd[1], _y + rd[2]
            local dx, dy = x - _x, y - _y
            local sx, sy = sign(dx), sign(dy)
            local px, py = dx * sx, dy * sy
            local max = px > py and px or py
            local scx, scy = dx / max, dy / max 

            for i = 1, max do
                if
                    w.walls[_x + math.floor(scx * i)][_y + math.floor(scy * i)]
                then
                    return false
                end
            end
        end
    end

    return true
end
