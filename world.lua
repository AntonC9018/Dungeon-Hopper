
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

    -- update enemy + player grid
    for i = 1, #self.entities_grid do
        for j = 1, #self.entities_grid[i] do
            self.entities_grid[i][j] = false
        end
    end
    for i = 1, #self.entities_list do
        self.entities_grid[self.entities_list[i].x][self.entities_list[i].y] = self.entities_list[i]
    end    

    self.entities_grid[self.player.x][self.player.y] = false

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

    self.entities_grid[self.player.x][self.player.y] = self.player


    for i = 1, #self.entities_list do
        if not self.entities_list[i].moved then
            self.entities_list[i]:performAction(player_action, self)
        end
    end

    -- environment stores such entities as bombs, traps
    -- projectiles, decorations and such 
    self.environment:act(self)

    
    environment:toFront()

    -- bring the entities that have higher y to the front
    table.sort(self.entities_list, function(a, b) return a.y > b.y end)
    for i = 1, #self.entities_list do
        self.entities_list[i].sprite:toFront()
    end




    -- animate all enemies
    for i = #self.entities_list, 1, -1 do
        if self.entities_list[i] ~= self.player then
            self.entities_list[i]:playAnimation(self)       

            if (self.entities_list[i].dead) then
                table.remove(self.entities_list, i)                    
            end
        end
    end


    -- animate the player sprite and all its descendants (weapons so on)
    -- the callback function will be called nevertheless 
    -- (even if the player is not going to play an animation)
    self.player:playAnimation(
        self,
        function(event)
            -- when the animation ends
            if event.phase == "end" then 

                for i = #self.entities_list, 1, -1 do
                    self.entities_list[i]:reset(self)
                end

                print('  ')

                self.environment:reset()


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