
local Wizzrobe = require('enemies.wizzrobe')
local Player = require('base.player')
local Dagger = require('weapons.dagger')
local Shovel = require('base.shovel')
local Action = require('logic.action')
local Camera = require('game.camera')
local BasicTile = require('tiles.basic')
local Coals = require('tiles.coals')
local Water = require('tiles.water')
local Crate = require('environ.crate')
local Explosion = require('environ.explosion')
local BounceTrap = require('traps.bouncetrap')
local Dirt = require('walls.dirt')
local Item = require('base.item')

local Cat = require('weapons.cat')

local World = class('World')

function World:__construct(w, h, group)
    self.width = w
    self.height = h
    self.group = group
    self.loop_queue = {}
    self.doing_loop = false
    self.loop_count = 1

    self.entities = {}
    self.env_special_tiles = {}
    self.env_objects = {}
    self.env_bombs = {}
    self.env_explosions = {}
    self.env_traps = {}
    self.env_items = {}
    self.walls = {}

    self.grid = tdArray(self.width, self.height,
        function(i, j)
            local cell = {}

            local rntiles = math.random()

            -- if rntiles < 0.3 then
            --     cell.tile = Coals(i, j, self)
            --     table.insert(self.env_special_tiles, cell.tile)

            -- elseif rntiles < 0.6 then
            --     cell.tile = Water(i, j, self)
            --     table.insert(self.env_special_tiles, cell.tile)

            -- else
            --     cell.tile = BasicTile(i, j, self)
            -- end

            cell.tile = BasicTile(i, j, self)


            local rnents = math.random()

            if rnents < 0.2 then
                cell.entity = Crate(i, j, self)
                table.insert(self.entities, cell.entity)
            

            elseif rnents < 0.4 then
                -- local v = vec( math.random(-1, 1), math.random(-1, 1) )
                -- cell.trap = BounceTrap(v, i, j, self)
                -- table.insert(self.env_traps, cell.trap)
            

            elseif rnents < 0.8 then
                cell.wall = Dirt(i, j, self)
                table.insert(self.walls, cell.wall)
            end


            cell.items = {}

            return cell
        end
    )
    self.camera = Camera()
end



function World:initPlayer(x, y)
    self.player = Player(x, y, self)

    -- TODO: add sprites for dropped and undropped state
    local weapon = Item.createUndropped(Cat, self)
    self.player.inventory:equip(weapon)
    
    local shovel = Item.createUndropped(Shovel, self)
    self.player.inventory:equip(shovel)

    self.player:on('displaced', function(event, t)
        local x, y = self.player.pos:comps()
        local cell = self.grid[x][y]

        if cell.gold or #cell.items > 0 then

            t:set('pickup')

            if cell.gold then
                print(string.format("%d gold has been collected", cell.gold.am))
                table.insert(t.pickups, cell.gold)
                cell.gold = false
            end
        end


    end)

    table.insert(self.entities, self.player)
end


function World:populate(am)
    local rx = self.width - 8
    local w = (self.width - rx) / 2
    local ry = self.height - 8
    local h = (self.height - ry) / 2
    for i = 1, am do
        local e = Wizzrobe(
            math.random(rx) + w,
            math.random(ry) + h,
            self
        )

        e:orientTo(self.player)

        self:resetInGrid(e)
        table.insert(self.entities, e)
    end
end


function World:spawn(x, y, classname, t)
    local entity = classname(x, y, self)
    entity.moved = true

    table.insert(self.entities, entity)
    self:resetInGrid(entity)

    return entity
end



function World:dropGold(x, y, g)
    print(string.format("%d gold has been dropped", g.am))
    local cell = self.grid[x][y]
    if cell.gold then
        cell.gold = cell.gold + g
    else
        cell.gold = g
        g:drop(x, y, self)
    end
    return cell.gold
end


function World:removeFromGrid(e)
    local ps = e:getPositions()
    for i = 1, #ps do
        local x, y = ps[i]:comps()
        self.grid[x][y][ e.socket_type ] = false
    end
end

function World:resetInGrid(e)
    local ps = e:getPositions()
    for i = 1, #ps do
        self.grid[ ps[i].x ][ ps[i].y ][ e.socket_type ] = e
    end
end


function World:sortByPriority()
    table.sort(self.entities, function(a, b)
        if a.priority == b.priority then
            return (a.pos - self.player.pos):mag() > (b.pos - self.player.pos):mag()
        else
            return a.priority > b.priority
        end
    end)
end

function World:sortByY(arr)
    table.sort(arr, function(a, b)
        if (a.pos.y == b.pos.y) then
            return a.zIndex < b.zIndex
        else
            return a.pos.y < b.pos.y
        end
    end)
end

function World:actEntities(player_action)
    for i = 1, #self.entities do
        if not self.entities[i].moved then
            self.entities[i]:act(player_action, self)
        end
    end
end

function World:toFront(arr)
    for i = 1, #arr do
        arr[i]:toFront()
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


-- explode the tiles within radius of r around the specified coordinate
function World:explode(x, y, r)
    -- the idea is to create an explosion for each of the tiles
    -- of a square, centered at (x, y), that has width of r
    for i = -r, r do
        for j = -r, r do
            self:explodeAt(x + i, y + j, vec(i, j):normComps())
        end
    end
end

function World:explodeAt(x, y, dir)
    local explosion = Explosion(dir, x, y, self)
    explosion:explode()
    table.insert(self.env_explosions, explosion)
end


function World:do_loop(player_action)
    player_action = Action(self.player, 'move/attack'):setDir(player_action)

    self.doing_loop = true

    -- TODO:
    -- self:actProjectiles()

    -- sort them by priority
    self:sortByPriority()
    self:actEntities(player_action)

    -- test of explosion
    -- self:explode(math.random(4, 10), math.random(4, 10), 1)


    for i = 1, #self.env_traps do
        if not self.env_traps[i].moved then
            self.env_traps[i]:act()
        end
    end

    for i = 1, #self.env_special_tiles do
        self.env_special_tiles[i]:act()
    end

    local things = {
        self.entities,
        self.walls,
        self.env_explosions,
        -- self.env_objects, -- not required, these are inside entities
        self.env_traps,
        self.env_bombs,
        self.env_items
    }

    local things_to_display = array_join_all(
        unpack( things )
    )

    -- bring the entities that have higher y to the front
    self:sortByY(things_to_display)
    self:toFront(things_to_display)

    -- Reset everything only when all animations have finished
    local I = #things_to_display

    local function refresh()

        for i = 1, #self.entities do
            self.entities[i]:tick()
            self.entities[i]:reset()
        end

        for i = 1, #self.env_explosions do
            self.env_explosions[i]:tick()
        end

        for i = 1, #self.env_traps do
            self.env_traps[i]:tick()
            self.env_traps[i]:reset()
        end

        print('------------------- LOOP ENDED -------------------')

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

    -- animate everything that needs to be animated
    for i = 1, #things do
        for j = #things[i], 1, -1 do
            things[i][j]:playAnimation(tryRefresh)

            if (things[i][j].dead) then
                table.remove(things[i], j)
            end
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