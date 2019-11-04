local Sizeful = class('Sizeful')

Sizeful.size = Vec(0, 0)

function Sizeful:__construct(x, y, w)
    self.pos = Vec(x, y)
    self.world = w
end


-- get positions that the creature occupies
function Sizeful:getPositions()
    local t = {}
    for i = 0, self.size.x do
        for j = 0, self.size.y do
            table.insert(t, self.pos + Vec(i, j))
        end
    end
    return t
end

function Sizeful:getOrthogonalPositions()
    local t = {}
    for i = 0, self.size.x do
        table.insert(t, self.p + Vec(i, -1))
        table.insert(t, self.p + Vec(i, 1 + self.size.y))
    end

    for j = 0, self.size.y do
        table.insert(t, self.p + Vec(-1, j))
        table.insert(t, self.p + Vec(1 + self.size.x, j))
    end
    return t
end



function Sizeful:getAdjacentPositions()
    local t = {}

    for i = -1, self.size.x + 1 do
        table.insert(t, self.p + Vec(i, -1))
        table.insert(t, self.p + Vec(i, 1 + self.size.y))
    end

    for j = 0, self.size.x do
        table.insert(t, self.p + Vec(-1, j))
        table.insert(t, self.p + Vec(1 + self.size.x, j))
    end

    return t
end



function Sizeful:getDiagonalPositions()
    return {
        self.p + Vec(-1, -1),
        self.p + Vec(self.size.x + 1, -1),
        self.p + Vec(-1, self.size.y + 1),
        self.p + self.size + Vec(1, 1)
    }
end


function Sizeful:getPointsFromDirection(v)
    local t = {}

    if v.x ~= 0 and v.y == 0 then

        if v.x > 0 then
            -- right
            for j = 0, self.size.y do
                table.insert(t, self.pos + Vec(self.size.x + 1, j))
            end
        else
            -- left
            for j = 0, self.size.y do
                table.insert(t, self.pos + Vec(-1, j))
            end
        end

    elseif v.y ~= 0 and v.x == 0 then

        if v.y > 0 then
            -- bottom
            for i = 0, self.size.x do
                table.insert(t, self.pos + Vec(i, self.size.y + 1))
            end
        else
            -- top
            for i = 0, self.size.x do
                table.insert(t, self.pos + Vec(i, -1))
            end
        end

    else -- got diagonal direction

        if v.x > 0 then

            if v.y > 0 then
                -- bottom right
                table.insert(t, self.pos + self.size + Vec(1, 1))

                for i = 1, self.size.x do
                    table.insert(t, self.pos + Vec(i, self.size.y + 1))
                end

                for i = 1, self.size.y do
                    table.insert(t, self.pos + Vec(self.size.x + 1, i))
                end
            else
                -- top right
                table.insert(t, self.pos + Vec(self.size.x + 1, -1))

                for i = 1, self.size.x do
                    table.insert(t, self.pos + Vec(i, -1))
                end

                for i = 0, self.size.y - 1 do
                    table.insert(t, self.pos + Vec(self.size.x + 1, i))
                end
            end

        else

            if v.y > 0 then
                -- bottom left
                table.insert(t, self.pos + Vec(-1, self.size.y + 1))

                for i = 0, self.size.x - 1 do
                    table.insert(t, self.pos + Vec(i, self.size.y + 1))
                end

                for i = 1, self.size.y do
                    table.insert(t, self.pos + Vec(-1, i))
                end

            else
                -- top left
                table.insert(t, self.pos + Vec(-1, -1))

                for i = 0, self.size.x - 1 do
                    table.insert(t, self.pos + Vec(i, -1))
                end

                for i = 0, self.size.y - 1 do
                    table.insert(t, self.pos + Vec(-1, i))
                end

            end

        end
    end
    return t
end

function Sizeful:getCenter()
    return (self.size + 1) * 0.5 + self.pos
end


function Sizeful:closeMath(p)
    local ss  = (self.size + 1) * 0.5
    local sp  = (p.size + 1) * 0.5
    local cs  = self.pos + ss
    local cp  = p.pos + sp
    local sss = ss + sp
    local dcs = (cs - cp):abs()

    return sss, dcs
end

function Sizeful:isClose(p)
    local sss, dcs = self:closeMath(p)
    return sss.x >= dcs.x and sss.y >= dcs.y and dcs.x ~= dcs.y
end

function Sizeful:isCloseDiagonal(p)
    local sss, dcs = self:closeMath(p)
    return sss.x >= dcs.x and sss.y >= dcs.y and dcs.x == dcs.y
end

function Sizeful:isCloseAdjacent(p)
    local sss, dcs = self:closeMath(p)
    return sss.x >= dcs.x and sss.y >= dcs.y
end

return Sizeful