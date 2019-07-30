
local Wizzrobe = require('enemies.wizzrobe')
local Player = require('base.player')
local Dagger = require('weapons.dagger')
local EnemyDagger = require('weapons.enemydagger')
local Action = require('logic.action')
local Camera = require('game.camera')
local BasicTile = require('tiles.basic')
local World = class('World')

function World:__construct(w, h, group)
    self.width = w
    self.height = h
    self.group = group
    self.loop_queue = {}
    self.doing_loop = false
    self.loop_count = 1
    self.entities = {}    

    self.grid = tdArray(self.width, self.height, 
        function(i, j)
            local t = {}

            if math.random() > 0.8 then
                -- t.wall = Dirt(i, j, self)
                -- table.insert(self.entities, d)
            end

            t.tile = BasicTile(i, j, self)

            return t
        end
    )
    self.camera = Camera()
end



function World:initPlayer(x, y)
    self.player = Player(x, y, self)

    local dagger = Dagger(self)
    self.player:equip(dagger)

    -- local spade = WoodenSpade(self)
    -- self.player.spade = spade

    -- self.player:on('animation:start', 
    --     function(p) 
    --         self.camera:sync(p, self:getAnimLength())    
    --     end
    -- )


    table.insert(self.entities, self.player)
end


function World:populate(a)
    local rx = self.width - 8
    local w = (self.width - rx) / 2
    local ry = self.height - 8
    local h = (self.height - ry) / 2
    for i = 1, a do
        local e = Wizzrobe(
            math.random(rx) + w, 
            math.random(ry) + h, 
            self
        )

        local w = Dagger(self)
        e.weapon = w

        self:resetEInGrid(e)
        table.insert(self.entities, e)
    end
end


function World:spawn(x, y, c) 
    local e = c(x, y, self)
    e.moved = true

    table.insert(self.entities, e)
    self:resetEInGrid(e)

    return e
end


function World:removeEFromGrid(e)
    local ps = e:getPositions()
    for i = 1, #ps do
        local x, y = ps[i]:comps()
        self.grid[x][y].entity = false
    end
end

function World:resetEInGrid(e)
    local ps = e:getPositions()
    for i = 1, #ps do
        self.grid[ps[i].x][ps[i].y].entity = e
    end
end


function World:sortByPriority()
    table.sort(self.entities, function(a, b) return a.priority > b.priority end)
end

function World:sortByY()
    table.sort(self.entities, function(a, b) return a.pos.y < b.pos.y end)
end

function World:actEntities(player_action)
    for i = 1, #self.entities do
        if not self.entities[i].moved then
            self.entities[i]:act(player_action, self)
        end
    end
end

function World:toFront()
    for i = 1, #self.entities do
        self.entities[i].sprite:toFront()
    end
end

-- function World:destroyWall(x, y)
--     self.walls[x][y]:destroy()
--     self.walls[x][y] = false
-- end


function World:isBlocked(x, y)
    if 
        self.grid[x][y].entity or 
        self.grid[x][y].object or
        self.grid[x][y].wall
    then
        return true
    end
    return false
end

function World:areBlockedAny(ps)
    for i = 1, #ps do
        if self:isBlocked(ps[i]:comps()) then
            return true
        end
    end
    return false
end

function World:do_loop(player_action)
    player_action = Action(self.player, 'move/attack'):setDir(player_action)

    self.doing_loop = true

    -- test of explosion
    -- self.env:explode(math.random(4, 6), math.random(4, 6), 1, self)

    -- TODO: 
    -- self:actProjectiles()

    -- sort them by priority
    self:sortByPriority()
    self:actEntities(player_action)

    --TODO: 
    -- self:actTraps()
    -- self:actTiles()   
    -- self.env:updateSprites()
    
    -- bring the entities that have higher y to the front
    self:sortByY()
    self:toFront()

    -- Reset everything only when all animations have finished
    local I = #self.entities

    local function refresh()
        for i = 1, #self.entities do   
            self.entities[i]:tick()         
            self.entities[i]:reset()            
        end

        -- update the iteration count
        self.loop_count = self.loop_count + 1

        -- if there are actions in the queue, do them
        if #self.loop_queue > 0 then
            self:do_loop(table.remove(self.loop_queue, 1))
        else
            self.doing_loop = false
        end
    end

    local function tryRefresh()
        I = I - 1
        if I == 0 then refresh() end
    end  

    self.camera:sync(self.player, self:getAnimLength())

    -- animate all entities
    for i = #self.entities, 1, -1 do

        self.entities[i]:playAnimation(tryRefresh)       

        if (self.entities[i].dead) then
            table.remove(self.entities, i)                    
        end    
    end
end

function World:getBeatOffset()
    -- if self.ignore -> return precise time
    -- else -> return edge time
end

function World:getAnimLength()
    return 230
end

function World:on_beat() 
    return true
end

return World