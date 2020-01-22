local Vec = class('vec')

function Vec:__construct(x, y)
    self.x = x
    self.y = y
end

Vec.__sub[Vec] = function(self, v)
    return Vec(
        self.x - v.x,
        self.y - v.y
    )
end

Vec.__add[Vec] = function(self, v)
    return Vec(
        self.x + v.x,
        self.y + v.y
    )
end

-- hadamard product (component-wise mult)
Vec.__mul[Vec] = function(self, v)
    return Vec(
        self.x * v.x,
        self.y * v.y
    )
end

-- dot (inner) product 
function Vec:dot(v)
    return self.x * v.x + self.y * v.y
end


Vec.__sub["number"] = function(self, n)
    return Vec(
        self.x - n, 
        self.y - n
    )
end

Vec.__add["number"] = function(self, n)
    return Vec(
        self.x + n, 
        self.y + n
    )
end

Vec.__mul["number"] = function(self, n)
    return Vec(
        self.x * n, 
        self.y * n
    )
end

Vec.__div["number"] = function(self, n)
    return Vec(
        self.x / n, 
        self.y / n
    )
end

function Vec:magSq()
    return self.x ^ 2 + self.y ^ 2
end

function Vec:mag()
    return math.sqrt(self:magSq())
end

function Vec:norm()
    local mag = self:mag()
    return Vec(
        self.x / mag,
        self.y / mag
    )
end

function Vec:normComps()
    return Vec(
        sign(self.x),
        sign(self.y)
    )
end

function Vec:rotate(rad)
    return Vec.matmul(
        self,
        Vec(math.cos(rad), -math.sin(rad)),
        Vec(math.sin(rad),  math.cos(rad))
    )
end

Vec.matmul = function(v, i, j)
    return Vec(
        i.x * v.x + j.x * v.y,
        i.y * v.x + j.y * v.y
    )
end

Vec.det = function(i, j)
    return i.x * j.y - i.y * j.x
end

function Vec:__unm()
    return Vec(
        -self.x,
        -self.y
    )
end

function Vec:angleBetween(v)
    return math.atan2(self:det(v), self:dot(v))
end

function Vec:copy()
    return Vec(
        self.x,
        self.y
    )
end

function Vec:comps()
    return self.x, self.y
end

function Vec:longest()
    local a = math.abs(self.x)
    local b = math.abs(self.y)
    return a > b and a or b
end

function Vec:abs()
    return Vec(
        math.abs(self.x),
        math.abs(self.y)
    )
end


function Vec:__tostring()
    return '{ x: '..tostring(self.x)..', y: '..tostring(self.y)..' }'
end


return Vec