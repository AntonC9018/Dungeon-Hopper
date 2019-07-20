local constructor = require('constructor')
local Environment = require('environment.environment')
local Player = require('player')
local Wizzrobe = require('enemies.wizzrobe')
local Dagger = require('weapons.dagger')
local Camera = require('camera')


local World = constructor:new()

function World:new(...)
    local o = constructor.new(self, unpack(arg))
    o.loop_queue = {}
    o.doing_loop = false
    o.loop_count = 1
    o.env = Environment:new{
        world = o
    }
    o.entities_grid = tdArray(o.width, o.height)
    o.walls = tdArray(o.width, o.height)
    o.camera = Camera:new{}
    o.entities_list = {}
    return o
end


function World:initPlayer(o)
    o.world = self
    local dagger = Dagger:new({ world = self })
    self.player = Player:new(o)
    self.player:equip(dagger)

    self.player:on('animation:start', 
        function(p, w) 
            w.camera:sync(p, w:getAnimLength())    
        end
    )


    table.insert(self.entities_list, self.player)
end


function World:populate(a)
    for i = 1, a do
        table.insert(
            self.entities_list, 
            Wizzrobe:new{
                x = math.random(self.width),
                y = math.random(self.height),
                world = self
            }
        )
    end
end


function World:spawn(x, y, class) 
    local entity = class:new{  
        x = x,
        y = y,
        world = self,
        doing_action = true,
        moved = true
    }
    table.insert(self.entities_list, entity)
    entity:resetPositions(self)
    return entity
end


function World:do_loop(player_action)

    self.doing_loop = true

    -- timer.cancel(self.timer_id)

    local on_beat = self:on_beat()

    -- check if the action is being done on beat

    --[[
        if self.ignore then

            -- player tries to get the action through after mashing the screen
            if player_action then return
            
            -- automatic beat timer acter mashing
            else
                self.ignore = false
                player.miss_beat_count = 0
            end
        end
    ]]--   


    --[[
        if not player_action or not on_beat then
            self.player:dropBeat()            
        end

        if not on_beat then
            if player.miss_beat_count > 3 then 
                self.ignore = true
            end
            return;
        end
    --]]

    --[[

        -- set interval for the next beat

        self.timer_id = timer.performWithDelay(self:getBeatOffset(), 
        
            function() 
                self:do_loop(nil)
            end,

            1
        )

    ]]--

    -- TODO: add projectiles

    -- update enemy + player grid
    for i = 1, #self.entities_grid do
        for j = 1, #self.entities_grid[i] do
            self.entities_grid[i][j] = false
        end
    end
    for i = 1, #self.entities_list do
        self.entities_list[i]:resetPositions(self)
    end

    -- player has priority
    -- update player's coordinates
    -- hit the enemy at the location
    -- do the same for their weapon (and spade?)
    self.player:act(player_action, self)


    self.player:resetPositions(self)


    -- test of explosion
    -- self.env:explode(math.random(4, 6), math.random(4, 6), 1, self)

    -- sort them by priority
    table.sort(self.entities_list, function(a, b) return a.priority > b.priority end)
    for i = 1, #self.entities_list do
        if not self.entities_list[i].moved then
            self.entities_list[i]:performAction(player_action, self)
        end
    end

    self.env:doTraps(self)
    
    self.env:doTiles(self)
    
    self.env:toFront('traps')
    self.env:updateSprites()

    -- bring the entities that have higher y to the front
    table.sort(self.entities_list, function(a, b) return a.y < b.y end)
    for i = 1, #self.entities_list do
        self.entities_list[i].sprite:toFront()
    end

    self.env:toFront('expls')


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