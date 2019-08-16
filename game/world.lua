
local Wizzrobe = require('enemies.wizzrobe')
local Player = require('base.player')
local Dagger = require('weapons.dagger')
local Action = require('logic.action')
local Camera = require('game.camera')
local BasicTile = require('tiles.basic')
local Coals = require('tiles.coals')
local Water = require('tiles.water')
local Crate = require('environ.crate')
local Explosion = require('environ.explosion')
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

    self.grid = tdArray(self.width, self.height,
        function(i, j)
            local cell = {}

            -- if math.random() > 0.8 then
            --     cell.tile = Coals(i, j, self)
            --     table.insert(self.env_special_tiles, cell.tile)

            -- elseif math.random() > 0.8 then
            --     cell.tile = Water(i, j, self)
            --     table.insert(self.env_special_tiles, cell.tile)

            -- else
            --     cell.tile = BasicTile(i, j, self)
            -- end

            if math.random() > 0.8 then
                cell.entity = Crate(i, j, self)
                table.insert(self.entities, cell.entity)
            end

            cell.tile = BasicTile(i, j, self)


            cell.items = {}

            return cell
        end
    )
    self.camera = Camera()
end



function World:initPlayer(x, y)
    self.player = Player(x, y, self)

    local dagger = Dagger(self)
    self.player.inventory:equip(dagger)

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

        self:resetEInGrid(e)
        table.insert(self.entities, e)
    end
end


function World:spawn(x, y, classname, t)
    local entity = classname(x, y, self)
    entity.moved = true

    table.insert(self.entities, entity)
    self:resetEInGrid(entity)

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
        self.grid[ ps[i].x ][ ps[i].y ].entity = e
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
    for i = 1, #self.env_explosions do
        self.env_explosions[i].sprite:toFront()
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
    self:explode(math.random(4, 6), math.random(4, 6), 1)

    --TODO:
    -- self:actTraps()
    -- self:actTiles()
    -- self.env:updateSprites()


    for i = 1, #self.env_special_tiles do
        self.env_special_tiles[i]:act()
    end

    -- bring the entities that have higher y to the front
    self:sortByY()
    self:toFront()

    -- Reset everything only when all animations have finished
    local I = #self.entities + #self.env_explosions

    local function refresh()

        for i = 1, #self.entities do
            self.entities[i]:tick()
            self.entities[i]:reset()
        end

        for i = 1, #self.env_explosions do
            self.env_explosions[i]:tick()
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

    for i = #self.env_explosions, 1, -1 do
        self.env_explosions[i]:playAnimation(tryRefresh)

        if (self.env_explosions[i].dead) then
            table.remove(self.env_explosions, i)
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