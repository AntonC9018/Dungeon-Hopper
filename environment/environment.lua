local constructor = require('constructor')
local Explosion = require('environment.explosion')
local BounceTrap = require('environment.bounceTrap')
local Tile = require('tiles.tile')
local Water = require('tiles.water')

local Environment = constructor:new{
    
}

function Environment:new(...)
    local o = constructor.new(self, unpack(arg))
    o.traps = {}
    o.bombs = {}
    -- items that lie on ground
    o.items = {}
    o.expls = {}
    o.tiles = tdArray(
        o.world.width, 
        o.world.height, 
        function(i, j)
            local t = math.random()
            print(t)
            if t > 0.9 then
                return Tile:new({
                    x = i,
                    y = j,
                    type = math.random(11),
                    world = o.world
                })
            else
                return Water:new({
                    x = i,
                    y = j,
                    type = 12,
                    world = o.world
                })
            end
        end
    )
    return o
end

function Environment:doTiles(w)
    for i = 1, #self.tiles do
        for j = 1, #self.tiles[i] do
            if w.entities_grid[i][j] then
                self.tiles[i][j]:activate(w.entities_grid[i][j], w)
            end
        end
    end
end

function Environment:doTraps(w)
    for i = 1, #self.traps do

        local t = self.traps[i]

        if t.active then
            if w.entities_grid[t.x][t.y] then
                t:activate(w.entities_grid[t.x][t.y], w)
            else
                t.bounced = false
            end
        end
    end
end

-- function Environment:doExpls(w)
--     for i = 1, #self.expls do


--     end
-- end

-- TODO: improve this, this is no good
function Environment:getTrapAt(x, y)
    for i = 1, #self.traps do
        if self.traps[i].x == x and self.traps[i].y == y then
            return self.traps[i]
        end
    end
end

-- TODO: improve this, this is no good
function Environment:getBombAt(x, y)
    for i = 1, #self.bomb do
        if self.bomb[i].x == x and self.bomb[i].y == y then
            return self.bomb[i]
        end
    end
end

-- TODO: improve this, this is no good
function Environment:getItemAt(x, y)
    for i = 1, #self.items do
        if self.items[i].x == x and self.items[i].y == y then
            return self.items[i]
        end
    end
end

function Environment:act(w)
    self:doTraps(w)
end

function Environment:updateSprites(w)
    for i = #self.expls, 1, -1 do
        local e = self.expls[i]
        if e.ended then 
            table.remove(self.expls, i)
            e.sprite:removeSelf()
        else
            e:tick()
        end
    end
end

function Environment:reset(w)
    for i = 1, #self.traps do
        local t = self.traps[i]
        if not w.entities_grid[t.x][t.y] then
            t:reset()
        end
    end     
    for i = 1, #self.tiles do
        for j = 1, #self.tiles[i] do
            self.tiles[i][j]:reset(w)
        end
    end
end

function Environment:toFront(str)
    for i = 1, #self[str] do
        self[str][i].sprite:toFront()
    end
end

-- explode the tiles within radius of r around the specified coordinate
function Environment:explode(x, y, r, w)
    -- the idea is to create an explosion for each of the tiles 
    -- of a square, centered at (x, y), that has width of r
    for i = -r, r do
        for j = -r, r do
            self:explodeAt(
                x + i, y + j, 
                normComps({ i, j }), 
                w
            )
        end
    end
    self.expls[#self.expls]:playAudio('boom')

end

function Environment:explodeAt(x, y, dir, w)
    local e = Explosion:new({ x = x, y = y, dir = dir, world = w })
    e:explode(w)
    table.insert(self.expls, e)
end

return Environment

