
-- an enum for response values
-- TODO: make a file for constants
FREE = 1
ENEMY = 2
WAIT = 3
BLOCK = 4
PLAYER = 5
NOTHING = 6

World = constructor:new{
    loop_queue = {},
    doing_loop = false
}


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

    -- update enemy grid
    for i = 1, #self.enemGrid do
        for j = 1, #self.enemGrid[i] do
            self.enemGrid[i][j] = false
        end
    end
    for i = 1, #self.enemList do
        self.enemGrid[self.enemList[i].x][self.enemList[i].y] = self.enemList[i]
    end    

    -- player has priority
    -- update player's coordinates
    -- hit the enemy at the location, update its:
    -- health (if not invincible)
    -- hurt = true 
    -- moved = true (if required)
    -- dead = true (if required)
    -- if dead, set animation string to death
    -- push it back (if required)
    -- set player's animation to the necessary string
    -- same for the audio
    -- do the same for their weapon (and spade?)
    self.player:act(player_action, self)

    -- also add the player to the grid
    self.enemGrid[self.player.x][self.player.y] = self.player


    local t = { table.unpack(self.enemList) }

    -- loop through enemList, set their 'moved' to false (except hit)
    -- set hit to false
    -- (update stunned?)


    local y = 0

    -- TODO: sort by proximity to the player, then do checks
    -- table.sort(t, function(a, b) 
        
    --     math.abs(self.player.x - a.x) + math.abs(self.player.y - a.y)
    
    -- end)

    for i = 1, #self.enemList do
        if not self.enemList[i].moved then
            self.enemList[i]:performAction(player_action, self)
        end
    end

    -- Environment (traps and such)
    local function trap(entity, _x, _y) 

        -- if entity.cur_action[1] or entity.cur_action[2] then return end

        local t = self.environment[_x][_y]

        if t ~= nil then

            local action = t:get_action(entity, self)

            -- if got push trap
            if action.name == 'push' then
                local x, y = _x + action.dir[1], _y + action.dir[2]

                if not self.walls[x][y] and not self.enemGrid[x][y] then
                    -- store the bounce
                    entity:bounce(action.dir, self)
                    -- repeat (could have hit another trap)
                    trap(entity, x, y)
                else
                    -- just hop a bit to the up
                    entity:bounce({ 0, 0 }, self)
                end
            end

            -- other cases coming soon
        end
    end

    -- react to the environment
    -- local t = { player, table.unpack(self.enemList) }
    -- for i = 1, #t do
    --     trap(t[i], t[i].x, t[i].y)
    -- end

    -- bring the entities that have higher y to the front
    table.sort(t, function(a, b) return a.y > b.y end)
    for i = 1, #t do
        t[i].sprite:toFront()

    end


    -- animate all enemies
    for i = #self.enemList, 1, -1 do
        self.enemList[i]:playAnimation(self)       

        if (self.enemList[i].dead) then
            table.remove(self.enemList, i)                    
        end
    end


    -- animate the player sprite and all its descendants (weapons so on)
    -- the callback function will be called nevertheless 
    -- (even if the player is not going to play an animation)
    self.player:play_animation(
        self,
        function(event)
            -- when the animation ends
            if event.phase == "end" then                
                self.player:reset()

                for i = #self.enemList, 1, -1 do
                    self.enemList[i]:reset(self)
                end

                -- if there are actions in the queue, do them
                if #self.loop_queue > 0 then
                    self:do_loop(table.remove(self.loop_queue, 1))
                else
                    self.doing_loop = false
                end
                
            end
        end
    )




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