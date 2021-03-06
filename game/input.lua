
-- Simply maps the keys to vectors and sets up 
-- the player's next action based on the input
-- This last part is done through the PlayerControl decorator
local input = function(world, log)
    local map = {
        up = Vec(0, -1),
        down = Vec(0, 1),
        left = Vec(-1, 0),
        right = Vec(1, 0),
        space = Vec(0, 0)
    }
    -- Add the key event listener
    Runtime:addEventListener( "key", 
        function(event)
            if event.phase ~= 'down' then
                return
            end
            local dir = map[event.keyName]
            if dir ~= nil then            
                local time = system.getTimer()
                world:setPlayerActions(dir, 1)
                world:gameLoop()
                if log then log() end
                printf("Time passed: %i", system.getTimer() - time)
                print("-------------- Cycle ended. ---------------")
            end
        end
    )
end


return input