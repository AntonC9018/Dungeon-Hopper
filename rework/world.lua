local World = class(World)

function World:__constructor()
    self.loop_queue = {}
    self.doing_loop = false
    self.loop_count = 1
    self.entities = {}

    self.grid = tdArray(self.width, self.height, 
        function(i, j)
            local t = {}

            if math.random() > 0.8 then
                t.wall = Dirt(i, j, self)
                table.insert(self.entities, d)
            end

            t.tile = Tile(i, j, self)

            return t
        end
    )
    -- o.camera = Camera:new{}
end



function World:initPlayer(x, y)
    self.player = Player(x, y, self)

    local whip = Whip(self)
    self.player:equip(whip)

    local spade = WoodenSpade(self)
    self.player.spade = spade

    self.player:on('animation:start', 
        function(p) 
            self.camera:sync(p, self:getAnimLength())    
        end
    )


    table.insert(self.entities, self.player)
end


function World:populate(a)
    for i = 1, a do
        local e = Wizzrobe(
            math.random(self.width), 
            math.random(self.height), 
            self
        )
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
        self.grid[ps[i].x][ps[i].j].entity = e
    end
end


function World:sortByPriority()
    table.sort(self.entities, function(a, b) return a.priority > b.priority end)
end

function World:sortByY()
    table.sort(self.entities, function(a, b) return a.y < b.y end)
end

function World:actEntities()
    for i = 1, #self.entities do
        if not self.entities[i].moved then
            self.entities[i]:act(player_action, self)
        end
    end
end

function World:toFront()
    for i = 1, #self.entities_list do
        self.entities_list[i].sprite:toFront()
    end   
    self.env:toFront('traps')
    self.env:toFront('expls')
end

function World:destroyWall(x, y)
    self.walls[x][y]:destroy()
    self.walls[x][y] = false
end

function World:do_loop(player_action)

    self.doing_loop = true

    -- test of explosion
    -- self.env:explode(math.random(4, 6), math.random(4, 6), 1, self)

    -- TODO: 
    -- self:actProjectiles()

    -- sort them by priority
    self:sortByPriority()
    self:actEntities()

    --TODO: 
    -- self:actTraps()
    -- self:actTiles()   
    -- self.env:updateSprites()
    
    -- bring the entities that have higher y to the front
    self:sortByY()
    self:toFront()

    -- Reset everything only when all animations have finished
    local I = #self.entities_list

    local function refresh()
        for i = 1, #self.entities_list do            
            self.entities_list[i]:reset(self)            
        end

        self.env:reset(self)


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

    -- animate all enemies
    for i = #self.entities_list, 1, -1 do

        self.entities_list[i]:playAnimation(self, tryRefresh)       

        if (self.entities_list[i].dead) then
            table.remove(self.entities_list, i)                    
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