Controller = constructor:new{
    anim_queue = {},
    doing_loop = false
}


function Controller:do_loop(player_action)

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

    -- player has priority
    -- update player's coordinates
    -- hit the enemy at the location, update its:
    -- health (if not invincible)
    -- hit = true 
    -- moved = true (if required)
    -- dead = true (if required)
    -- if dead, set animation string to death
    -- push it back (if required)
    -- set player's animation to the necessary string
    -- same for the audio
    -- do the same for their weapon (and spade?)
    self.player:act(player_action, self)


    local t = {}

    -- loop through enemList, set their 'moved' to false (except hit)
    -- set hit to false
    -- (update stunned?)
    for i = 1, #self.enemList do
        if (not self.enemList[i].hit) then
            self.enemList.moved = false
            table.insert(t, self.enemList[i])
        end
    end

    -- reapeat until all enemies have moved
    while #t ~= 0 do

        -- Figure out the next action of the enemies
        -- go from the back of the array to be able to remove elements
        for i = #t, 1, -1 do

            -- if the player is not in radius, ignore
            if not t[i].sees then 
                t[i].moved = true
                table.remove(t, i)            
            else 
                -- the enemy would spit out an array of desired actions
                -- elements to the left are most desired, to the right - least
                -- the array is of configuration { { x, y, (specs) {} }, ... }
                local desActs = t[i]:getAction(player_action, self)

                -- if the action specified is doing nothing
                if #desActs == 0 then
                    t[i]:loiter(self)
                    t[i].moved = true
                    table.remove(t, i)
                end

                -- responds, i.e. answers of the environment
                local resps = {}                

                for j = 1, #desActs do
                    local x, y, s = desActs[j]
                    

                    local en = self.enemGrid[x][y]

                    --[[

                    !!!This might be changed in the future!!!

                        1 - free way, no enemy or block
                        2 - an enemy is blocking the spot
                        3 - there is an enemy but they haven't moved yet
                        4 - there is a block on the way
                        
                        {? the durability of that block 
                            5 - dirt
                            6 - stone
                            7 - obsidian
                            8 - bedrock
                        }?
                    ]]--

                    if self.walls[x][y] then
                        -- there is a wall
                        resps[j] = 4
                    else

                        -- the simplest case unblocked way
                        if not en then 
                            resps[j] = 1
                            break
                        -- an enemy has moved to the spot
                        elseif en.moved then
                            -- if the enemy is dead it's valid
                            if en.dead then
                                resps[j] = 1
                                break
                            else
                                resps[j] = 2 
                            end
                        else 
                            -- the enemy is going to move later
                            resps[j] = 3
                            break
                        end
                    end
                end

                local all_blocked = true

                -- loop through all possible actions
                -- remember, they are ordered by desirability
                for j = 1, #resps do
                    -- wait for the enemy to move out of the way
                    if resps[j] == 3 then 
                        all_blocked = false 
                        break 
                    end
                    -- move if can move
                    if resps[j] == 1 then
                        -- move / hit the player
                        -- Note: if the player has been hit by this, the audio
                        -- of the player would also be changed
                        t[i]:move(j, self)
                        t[i].moved = true
                        table.remove(t, i)
                        all_blocked = false
                    end
                end

                -- if nowhere to go 
                if all_blocked then
                    -- would also trigger if there's no action in the resps list
                    t[i]:bump(1, self)
                    t[i].moved = true
                    table.remove(t, i)
                end
                
            end -- / resps loop
        end -- / #t loop
    end -- / while t loop
    

    -- Environment (traps and such)
    local function trap(entity, _x, _y) 

        if entity.cur_action[1] or entity.cur_action[2] then return end

        local t = self.environment[_x][_y]

        if t ~= nil then

            local action = t:get_action(entity, self)

            -- if got push trap
            if action.name == 'push' then
                local x, y = _x + action.dir[1], _y + action.dir[2]

                if not self.walls[x][y] and not self.enemGrid[x][y] then
                    -- store the bounce
                    entity:bounce(action.dir, self)
                    -- reapeat (could have hit another trap)
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
    
    -- player is invincible (flickering)
    if self.player.flicker ~= nil then

        -- keep track of how many beats the player has been flickering
        self.player.flicker_count = self.player.flicker_count + 1

        -- exceeded flicker limit
        if (self.player.flicker_count > self.player.flicker_max) then
            -- stop flickering
            transition.cancel(self.player.flicker)
            -- restore alpha
            transition.to(self.player.sprite, {
                alpha = 1,
                time = 100
            })
            self.player.flicker = nil
        end 

    end

    -- animate all enemies
    for i = 1, #self.enemList do
        self.enemList[i]:play_audio()
        self.enemList[i]:play_animation()
    end

    self.player:play_audio()

    -- animate the player sprite and all its descendants (weapons so on)
    -- the callback function will be called nevertheless 
    -- (even if the player is not going to play an animation)
    self.player:play_animation(
        function(event)
            -- when the animation ends
            if event.phase == "end" then
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

function Controller:getBeatOffset()
    -- if self.ignore -> return precise time
    -- else -> return edge time
end

function Controller:getAnimLength()
    return 160
end

function Controller:on_beat() 
    return true
end