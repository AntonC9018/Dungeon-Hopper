
DEBUFFS = {'stun', 'confuse', 'tiny', 'poison', 'fire', 'freeze'}

SPECIAL = {'push', 'pierce'}


FREE = 1
ENEMY = 2
WAIT = 3
BLOCK = 4
PLAYER = 5
NOTHING = 6


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
