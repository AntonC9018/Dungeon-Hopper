local vec = class('vec')

function vec:__construct(x, y)
    self.x = x
    self.y = y
end

vec.__sub[vec] = function(self, v)
    return vec(
        self.x - v.x,
        self.y - v.y
    )
end

vec.__add[vec] = function(self, v)
    return vec(
        self.x + v.x,
        self.y + v.y
    )
end

-- hadamard product (component-wise mult)
vec.__mul[vec] = function(self, v)
    return vec(
        self.x * v.x,
        self.y * v.y
    )
end

-- dot (inner) product 
function vec:dot(v)
    return self.x * v.x + self.y * v.y
end


vec.__sub["number"] = function(self, n)
    return vec(
        self.x - n, 
        self.y - n
    )
end

vec.__add["number"] = function(self, n)
    return vec(
        self.x + n, 
        self.y + n
    )
end

vec.__mul["number"] = function(self, n)
    return vec(
        self.x * n, 
        self.y * n
    )
end

vec.__div["number"] = function(self, n)
    return vec(
        self.x / n, 
        self.y / n
    )
end

function vec:magSq()
    return self.x ^ 2 + self.y ^ 2
end

function vec:mag()
    return math.sqrt(self:magSq())
end

function vec:norm()
    local mag = self:mag()
    return vec(
        self.x / mag,
        self.y / mag
    )
end

function vec:normComps()
    return vec(
        sign(self.x),
        sign(self.y)
    )
end

function vec:rotate(rad)
    return vec.matmul(
        self,
        vec(math.cos(rad), -math.sin(rad)),
        vec(math.sin(rad),  math.cos(rad))
    )
end

vec.matmul = function(v, i, j)
    return vec(
        i.x * v.x + j.x * v.y,
        i.y * v.x + j.y * v.y
    )
end

vec.det = function(i, j)
    return i.x * j.y - i.y * j.x
end

function vec:__unm()
    return vec(
        -self.x,
        -self.y
    )
end

function vec:angleBetween(v)
    return math.atan2(self:det(v), self:dot(v))
end

function vec:copy()
    return vec(
        self.x,
        self.y
    )
end

function vec:comps()
    return self.x, self.y
end

function vec:longest()
    local a = math.abs(self.x)
    local b = math.abs(self.y)
    return a > b and a or b
end

function vec:abs()
    return vec(
        math.abs(self.x),
        math.abs(self.y)
    )
end


function vec:__tostring()
    return '{ x: '..tostring(self.x)..', y: '..tostring(self.y)..' }'

end
return vec